import Foundation
import Combine

// MARK: - Wordle Game State

enum LetterResult {
    case unknown
    case correct
    case present
    case absent
}

struct WordleGameState {
    var guesses: [[String]] = []          // letters for each attempt
    var results: [[LetterResult]] = []    // result state for each letter
    var currentAttempt: Int = 0
    var wordLength: Int = 5
    var isGameOver: Bool = false
    var isGameWon: Bool = false
    var hintsUsed: Int = 0
}

// MARK: - Wordle Game

class WordleGame: ObservableObject, Game {
    let id = "wordle"
    let name = "Wordle"
    let description = "Guess the letters to find the Bisaya word"
    
    var difficulty: DifficultyLevel = .medium
    
    @Published var gameState = WordleGameState()
    
    private var currentWord: Vocabulary?
    private var correctGuesses: Int = 0
    private var totalAttempts: Int = 0
    private var startTime: Date?
    private let maxAttempts = 6
    // Keep recent words to avoid repeats
    private var recentWords: [String] = []
    
    private weak var dataManager: DataManager?
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        // Load persisted recentWords from GameManager
        recentWords = GameManager.shared.playerProgress.recentWords
    }

    // Allow views to attach the environment DataManager instance
    func attachDataManager(_ manager: DataManager) {
        self.dataManager = manager
    }

    // MARK: - Game Protocol Implementation

    func startNewGame() -> WordleGameState {
        // Filter words by difficulty range and length (max 6 characters) to keep grid manageable
        let minDiff = GameManager.shared.playerProgress.minDifficulty
        let maxDiff = GameManager.shared.playerProgress.maxDifficulty
        func diffOrder(_ d: DifficultyLevel) -> Int {
            switch d {
            case .easy: return 0
            case .medium: return 1
            case .hard: return 2
            }
        }
        let minOrd = diffOrder(minDiff)
        let maxOrd = diffOrder(maxDiff)

        let words = (dataManager?.vocabulary ?? []).filter { item in
            let ord = diffOrder(item.difficulty)
            return ord >= minOrd && ord <= maxOrd && item.word.count <= 6
        }
        guard !words.isEmpty else { return gameState }

        // Exclude recently used words (rotate through pool)
        var available = words.filter { !recentWords.contains($0.word) }
        if available.isEmpty {
            // All words exhausted, reset recent list and allow reuse
            recentWords = []
            available = words
        }

        // Log the candidate pool
        // print("Wordle pool: \(available.map { $0.word })")

        // Randomize selection from available pool
        currentWord = available.randomElement()
        if let chosen = currentWord?.word {
            // Track recent selections (keep up to 20)
            recentWords.insert(chosen, at: 0)
            if recentWords.count > 20 { recentWords.removeLast() }
            // Persist recent words
            GameManager.shared.updateRecentWords(recentWords)
            // print("Wordle chosen: \(chosen)")
        }
        let length = currentWord?.word.count ?? 5
        gameState = WordleGameState()
        gameState.wordLength = length
        gameState.currentAttempt = 0
        gameState.isGameOver = false
        gameState.isGameWon = false
        gameState.hintsUsed = 0

        // Initialize empty guesses and results
        gameState.guesses = Array(repeating: Array(repeating: "", count: length), count: maxAttempts)
        gameState.results = Array(repeating: Array(repeating: .unknown, count: length), count: maxAttempts)

        startTime = Date()
        totalAttempts = 0
        correctGuesses = 0

        return gameState
    }

    func guessWord(_ guess: String) -> WordleGameState {
        guard !gameState.isGameOver, let solution = currentWord?.word.lowercased() else { return gameState }
        let cleaned = guess.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard cleaned.count == gameState.wordLength else { return gameState }

        let guessChars = Array(cleaned)
        var solutionChars = Array(solution)
        var result = Array(repeating: LetterResult.absent, count: gameState.wordLength)

        // First pass: correct positions
        for i in 0..<gameState.wordLength {
            if guessChars[i] == solutionChars[i] {
                result[i] = .correct
                solutionChars[i] = "\0" // mark used
            }
        }

        // Second pass: present but wrong position
        for i in 0..<gameState.wordLength {
            if result[i] == .correct { continue }
            if let idx = solutionChars.firstIndex(of: guessChars[i]) {
                result[i] = .present
                solutionChars[idx] = "\0"
            } else {
                result[i] = .absent
            }
        }

        // Save guess and results
        let attempt = gameState.currentAttempt
        gameState.guesses[attempt] = guessChars.map { String($0) }
        gameState.results[attempt] = result

        // Update overall state
        if result.allSatisfy({ $0 == .correct }) {
            gameState.isGameWon = true
            gameState.isGameOver = true
            correctGuesses += 1
        } else if attempt + 1 >= maxAttempts {
            gameState.isGameOver = true
        } else {
            gameState.currentAttempt += 1
        }

        totalAttempts += 1
        return gameState
    }

    // Return the current solution word (for end-of-game display)
    func revealSolution() -> String? {
        return currentWord?.word
    }

    // Keep ABI for hints
    func useHint() -> String? {
        guard let word = currentWord, gameState.hintsUsed < 2 else { return nil }
        gameState.hintsUsed += 1
        return "This is a \(word.partOfSpeech). Translation: \(word.translation)"
    }

    func getScore() -> GameScore {
        let timeSpent = Date().timeIntervalSince(startTime ?? Date())
        let percentage = totalAttempts > 0 ? Double(correctGuesses) / Double(totalAttempts) * 100 : 0

        return GameScore(
            correctAnswers: correctGuesses,
            totalAttempts: totalAttempts,
            percentage: percentage,
            timeSpent: timeSpent
        )
    }

    func reset() {
        gameState = WordleGameState()
        correctGuesses = 0
        totalAttempts = 0
        currentWord = nil
        startTime = nil
    }
}
