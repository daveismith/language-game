import Foundation
import Yams
import Combine

// MARK: - Data Manager

class DataManager: NSObject, ObservableObject {
    @Published var vocabulary: [Vocabulary] = []
    @Published var numbers: [BisayaNumber] = []
    @Published var isLoading = false
    @Published var lastError: String? = nil
    
    static let shared = DataManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    override init() {
        let cachePaths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        self.cacheDirectory = cachePaths[0].appendingPathComponent("bisaya-learning-data")
        super.init()
        
        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Load cached data
        loadCachedData()
    }
    
    // MARK: - Public Methods
    
    func fetchDataFromRepository(url: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.lastError = nil
        }
        
        do {
            let repoURL = normalizeGitURL(url)
            try await cloneOrPullRepository(repoURL)
            loadCachedData()
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.lastError = "Failed to fetch data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func loadCachedData() {
        do {
            // Load vocabulary
            if let vocabData = try loadYAMLFile(named: "vocabulary.yaml", decodeTo: VocabularyData.self) {
                DispatchQueue.main.async {
                    self.vocabulary = vocabData.vocabulary
                }
            }
            
            // Load numbers
            if let numbersData = try loadYAMLFile(named: "numbers.yaml", decodeTo: NumbersData.self) {
                DispatchQueue.main.async {
                    self.numbers = numbersData.numbers
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.lastError = "Failed to load cached data: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func cloneOrPullRepository(_ repoURL: String) async throws {
        let repoPath = cacheDirectory.appendingPathComponent("repo").path
        
        // Check if repo exists
        if fileManager.fileExists(atPath: repoPath) {
            // Pull latest changes
            try await runCommand("git", arguments: ["-C", repoPath, "pull"])
        } else {
            // Clone repository
            try await runCommand("git", arguments: ["clone", repoURL, repoPath])
        }
    }
    
    private func runCommand(_ command: String, arguments: [String]) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "\(command) \(arguments.joined(separator: " "))"]
        
        let pipe = Pipe()
        process.standardError = pipe
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw DataFetchError.commandFailed(output)
        }
    }
    
    private func loadYAMLFile<T: Decodable>(named: String, decodeTo: T.Type) throws -> T? {
        let filePath = cacheDirectory.appendingPathComponent("repo").appendingPathComponent(named)
        
        guard fileManager.fileExists(atPath: filePath.path) else {
            return nil
        }
        
        let content = try String(contentsOf: filePath, encoding: .utf8)
        let decoded = try YAMLDecoder().decode(T.self, from: content)
        return decoded
    }
    
    private func normalizeGitURL(_ url: String) -> String {
        // Ensure URL ends with .git for proper git operations
        if url.hasSuffix(".git") {
            return url
        }
        return url.appending(".git")
    }
}

// MARK: - Errors

enum DataFetchError: LocalizedError {
    case commandFailed(String)
    case invalidURL
    case decodingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .commandFailed(let message):
            return "Command failed: \(message)"
        case .invalidURL:
            return "Invalid repository URL"
        case .decodingFailed(let message):
            return "Failed to decode data: \(message)"
        }
    }
}
