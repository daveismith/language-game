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
            // Try to load from the provided path/URL
            if url.hasPrefix("file://") || url.hasPrefix("/") {
                // Local file path
                try await loadFromLocalPath(url)
            } else if url.hasPrefix("http://") || url.hasPrefix("https://") {
                // Remote URL - fetch raw files
                try await loadFromRemoteURL(url)
            } else {
                // Treat as local path
                try await loadFromLocalPath(url)
            }
            
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
    
    private func loadFromLocalPath(_ path: String) async throws {
        // Remove file:// prefix if present
        var cleanPath = path
        if cleanPath.hasPrefix("file://") {
            cleanPath = String(cleanPath.dropFirst(7))
        }
        
        let baseURL = URL(fileURLWithPath: cleanPath)
        
        // Try to load vocabulary.yaml
        let vocabURL = baseURL.appendingPathComponent("vocabulary.yaml")
        if fileManager.fileExists(atPath: vocabURL.path) {
            do {
                let content = try String(contentsOf: vocabURL, encoding: .utf8)
                let vocabData = try YAMLDecoder().decode(VocabularyData.self, from: content)
                // Cache the content
                try saveToCacheDirectory(filename: "vocabulary.yaml", content: content)
                DispatchQueue.main.async {
                    self.vocabulary = vocabData.vocabulary
                }
            } catch {
                // Silently fail for individual files
            }
        }
        
        // Try to load numbers.yaml
        let numbersURL = baseURL.appendingPathComponent("numbers.yaml")
        if fileManager.fileExists(atPath: numbersURL.path) {
            do {
                let content = try String(contentsOf: numbersURL, encoding: .utf8)
                let numbersData = try YAMLDecoder().decode(NumbersData.self, from: content)
                // Cache the content
                try saveToCacheDirectory(filename: "numbers.yaml", content: content)
                DispatchQueue.main.async {
                    self.numbers = numbersData.numbers
                }
            } catch {
                // Silently fail for individual files
            }
        }
    }
    
    private func loadFromRemoteURL(_ urlString: String) async throws {
        var baseURLString = urlString
        // Normalize the URL
        if baseURLString.hasSuffix(".git") {
            baseURLString = String(baseURLString.dropLast(4))
        }
        
        // For GitHub URLs, convert to raw content URL
        if baseURLString.contains("github.com") {
            baseURLString = baseURLString
                .replacingOccurrences(of: "github.com", with: "raw.githubusercontent.com")
                .replacingOccurrences(of: "/tree/", with: "/")
                .appending("/main")
        }
        
        // Load vocabulary.yaml
        let vocabURLString = baseURLString + "/vocabulary.yaml"
        do {
            let vocabData = try await fetchAndDecodeYAML(urlString: vocabURLString, decodeTo: VocabularyData.self)
            // Get the raw content for caching
            let vocabContent = try await fetchRawYAML(urlString: vocabURLString)
            try saveToCacheDirectory(filename: "vocabulary.yaml", content: vocabContent)
            DispatchQueue.main.async {
                self.vocabulary = vocabData.vocabulary
            }
        } catch {
            // Silently fail - optional file
        }
        
        // Load numbers.yaml
        let numbersURLString = baseURLString + "/numbers.yaml"
        do {
            let numbersData = try await fetchAndDecodeYAML(urlString: numbersURLString, decodeTo: NumbersData.self)
            // Get the raw content for caching
            let numbersContent = try await fetchRawYAML(urlString: numbersURLString)
            try saveToCacheDirectory(filename: "numbers.yaml", content: numbersContent)
            DispatchQueue.main.async {
                self.numbers = numbersData.numbers
            }
        } catch {
            // Silently fail - optional file
        }
    }
    
    private func fetchAndDecodeYAML<T: Decodable>(urlString: String, decodeTo: T.Type) async throws -> T {
        let content = try await fetchRawYAML(urlString: urlString)
        let decoded = try YAMLDecoder().decode(T.self, from: content)
        return decoded
    }
    
    private func fetchRawYAML(urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw DataFetchError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let content = String(data: data, encoding: .utf8) ?? ""
        return content
    }
    
    private func saveToCacheDirectory(filename: String, content: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    private func loadYAMLFile<T: Decodable>(named: String, decodeTo: T.Type) throws -> T? {
        let filePath = cacheDirectory.appendingPathComponent(named)
        
        guard fileManager.fileExists(atPath: filePath.path) else {
            return nil
        }
        
        let content = try String(contentsOf: filePath, encoding: .utf8)
        let decoded = try YAMLDecoder().decode(T.self, from: content)
        return decoded
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
