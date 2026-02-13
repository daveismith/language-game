import Foundation

class GameManager: ObservableObject {
    @Published var playerProgress: PlayerProgress
    
    static let shared = GameManager()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults = UserDefaults.standard
    private let progressKey = "playerProgress"
    
    init() {
        if let data = userDefaults.data(forKey: progressKey),
           let decoded = try? decoder.decode(PlayerProgress.self, from: data) {
            self.playerProgress = decoded
        } else {
            self.playerProgress = PlayerProgress(
                studentName: "Student",
                dataSourceURL: ""
            )
        }
    }
    
    // MARK: - Public Methods
    
    func updateDataSourceURL(_ url: String) {
        playerProgress.dataSourceURL = url
        saveProgress()
    }
    
    func updateStudentName(_ name: String) {
        playerProgress.studentName = name
        saveProgress()
    }
    
    func recordGamePlay(gameType: GameType, score: Double, totalAttempts: Int) {
        let stat = GameStat(gameType: gameType, score: score, totalAttempts: totalAttempts)
        playerProgress.recordGameStat(stat)
        saveProgress()
    }
    
    func getGameStats(for gameType: GameType) -> [GameStat] {
        return playerProgress.gamesPlayed.filter { $0.gameType == gameType.rawValue }
    }
    
    func getAverageScore(for gameType: GameType) -> Double {
        let stats = getGameStats(for: gameType)
        guard !stats.isEmpty else { return 0 }
        let sum = stats.reduce(0) { $0 + $1.score }
        return sum / Double(stats.count)
    }
    
    // MARK: - Private Methods
    
    private func saveProgress() {
        if let encoded = try? encoder.encode(playerProgress) {
            userDefaults.set(encoded, forKey: progressKey)
        }
    }
}
