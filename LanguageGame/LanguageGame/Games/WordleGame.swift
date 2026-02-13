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
    
    private weak var dataManager: DataManager?
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
    }

    // Allow views to attach the environment DataManager instance
    func attachDataManager(_ manager: DataManager) {
        self.dataManager = manager
    }

    // MARK: - Game Protocol Implementation

    func startNewGame() -> WordleGameState {
        // Filter words by difficulty and length (max 6 characters) to keep grid manageable
        let words = (dataManager?.vocabulary ?? []).filter { $0.difficulty == difficulty && $0.word.count <= 6 }
        guard !words.isEmpty else { return gameState }

        // Randomize selection
        currentWord = words.shuffled().first
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
