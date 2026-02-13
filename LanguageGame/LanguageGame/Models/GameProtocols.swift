import Foundation

// MARK: - Game Protocol

protocol Game: AnyObject {
    associatedtype GameState
    
    var id: String { get }
    var name: String { get }
    var description: String { get }
    var difficulty: DifficultyLevel { get set }
    
    func startNewGame() -> GameState
    func getScore() -> GameScore
    func reset()
}

// MARK: - Game Score

struct GameScore {
    let correctAnswers: Int
    let totalAttempts: Int
    let percentage: Double
    let timeSpent: TimeInterval
    
    var displayScore: String {
        "\(correctAnswers)/\(totalAttempts)"
    }
    
    var displayPercentage: String {
        String(format: "%.0f%%", percentage)
    }
}

// MARK: - Game Types

enum GameType: String, CaseIterable {
    case wordle
    case hangman
    case numberQuiz
    
    var displayName: String {
        switch self {
        case .wordle:
            return "Wordle"
        case .hangman:
            return "Hangman"
        case .numberQuiz:
            return "Number Quiz"
        }
    }
    
    var description: String {
        switch self {
        case .wordle:
            return "Guess the letters to find the Bisaya word"
        case .hangman:
            return "Guess letters before the hangman is complete"
        case .numberQuiz:
            return "Match Bisaya numbers to their numeric values"
        }
    }
}

// MARK: - Player Progress

struct PlayerProgress: Codable {
    var studentName: String
    var dataSourceURL: String
    var gamesPlayed: [GameStat] = []
    var lastUpdated: Date = Date()
    var minDifficulty: DifficultyLevel = .easy
    var maxDifficulty: DifficultyLevel = .hard
    var recentWords: [String] = []
    
    mutating func recordGameStat(_ stat: GameStat) {
        gamesPlayed.append(stat)
    }

    mutating func updateRecentWords(_ words: [String]) {
        recentWords = words
    }
}

struct GameStat: Codable, Identifiable {
    let id: UUID
    let gameType: String
    let score: Double
    let totalAttempts: Int
    let playedAt: Date
    
    init(gameType: GameType, score: Double, totalAttempts: Int) {
        self.id = UUID()
        self.gameType = gameType.rawValue
        self.score = score
        self.totalAttempts = totalAttempts
        self.playedAt = Date()
    }
}
