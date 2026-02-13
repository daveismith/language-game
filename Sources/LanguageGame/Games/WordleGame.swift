import Foundation

// MARK: - Wordle Game State

struct WordleGameState {
    var displayWord: String = ""
    var guessedLetters: Set<String> = []
    var wrongGuesses: Set<String> = []
    var isGameOver: Bool = false
    var isGameWon: Bool = false
    var hintsUsed: Int = 0
}

// MARK: - Wordle Game

class WordleGame: Game {
    let id = "wordle"
    let name = "Wordle"
    let description = "Guess the letters to find the Bisaya word"
    
    var difficulty: DifficultyLevel = .medium
    
    private var currentWord: Vocabulary?
    private var gameState = WordleGameState()
    private var correctGuesses: Int = 0
    private var totalAttempts: Int = 0
    private var startTime: Date?
    
    private weak var dataManager: DataManager?
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Game Protocol Implementation
    
    func startNewGame() -> WordleGameState {
        // Select random word matching difficulty
        let words = (dataManager?.vocabulary ?? []).filter { $0.difficulty == difficulty }
        guard !words.isEmpty else {
            return gameState
        }
        
        currentWord = words.randomElement()
        gameState = WordleGameState()
        gameState.displayWord = String(repeating: "_ ", count: currentWord?.word.count ?? 0)
        startTime = Date()
        totalAttempts += 1
        
        return gameState
    }
    
    func guessLetter(_ letter: String) -> WordleGameState {
        guard !gameState.isGameOver, let word = currentWord?.word else {
            return gameState
        }
        
        let lowercaseLetter = letter.lowercased()
        
        // Check if already guessed
        if gameState.guessedLetters.contains(lowercaseLetter) {
            return gameState
        }
        
        gameState.guessedLetters.insert(lowercaseLetter)
        
        // Check if letter is in word
        if word.lowercased().contains(lowercaseLetter) {
            correctGuesses += 1
            updateDisplayWord()
            
            // Check if word is complete
            if !gameState.displayWord.contains("_") {
                gameState.isGameWon = true
                gameState.isGameOver = true
            }
        } else {
            gameState.wrongGuesses.insert(lowercaseLetter)
            
            // Check if max wrong guesses reached (6 for standard Wordle)
            if gameState.wrongGuesses.count >= 6 {
                gameState.isGameOver = true
            }
        }
        
        return gameState
    }
    
    func useHint() -> String? {
        guard let word = currentWord, gameState.hintsUsed < 2 else {
            return nil
        }
        
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
    
    // MARK: - Private Methods
    
    private func updateDisplayWord() {
        guard let word = currentWord?.word else { return }
        
        var display = ""
        for char in word.lowercased() {
            if gameState.guessedLetters.contains(String(char)) {
                display += String(char) + " "
            } else {
                display += "_ "
            }
        }
        gameState.displayWord = display
    }
}
