import Foundation
import Combine

// MARK: - Number Quiz Game State

struct NumberQuizGameState {
    enum PromptType {
        case numberToWord(Int)
        case wordToNumber(String)
    }
    
    var currentPrompt: PromptType?
    var userAnswer: String = ""
    var isAnswerCorrect: Bool?
    var isGameOver: Bool = false
}

// MARK: - Number Quiz Game

class NumberQuizGame: ObservableObject, Game {
    let id = "numberQuiz"
    let name = "Number Quiz"
    let description = "Match Bisaya numbers to their numeric values"
    
    var difficulty: DifficultyLevel = .medium
    
    @Published var gameState = NumberQuizGameState()
    private var correctGuesses: Int = 0
    private var totalAttempts: Int = 0
    private var startTime: Date?
    
    private weak var dataManager: DataManager?
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Game Protocol Implementation
    
    func startNewGame() -> NumberQuizGameState {
        gameState = NumberQuizGameState()
        startTime = Date()
        totalAttempts += 1
        generateNewPrompt()
        return gameState
    }
    
    func submitAnswer(_ answer: String) -> NumberQuizGameState {
        guard let prompt = gameState.currentPrompt else {
            return gameState
        }
        
        gameState.userAnswer = answer
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespaces).lowercased()
        
        switch prompt {
        case .numberToWord(let number):
            // User should provide Bisaya word
            if let matchingNumber = dataManager?.numbers.first(where: { $0.value == number }) {
                let isCorrect = trimmedAnswer == matchingNumber.bisaya.lowercased()
                gameState.isAnswerCorrect = isCorrect
                if isCorrect {
                    correctGuesses += 1
                }
            }
        case .wordToNumber(let bisayaWord):
            // User should provide numeric value
            if let number = Int(trimmedAnswer),
               let matchingNumber = dataManager?.numbers.first(where: { $0.bisaya.lowercased() == bisayaWord.lowercased() }) {
                let isCorrect = number == matchingNumber.value
                gameState.isAnswerCorrect = isCorrect
                if isCorrect {
                    correctGuesses += 1
                }
            } else {
                gameState.isAnswerCorrect = false
            }
        }
        
        return gameState
    }
    
    func nextQuestion() {
        generateNewPrompt()
        gameState.userAnswer = ""
        gameState.isAnswerCorrect = nil
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
        gameState = NumberQuizGameState()
        correctGuesses = 0
        totalAttempts = 0
        startTime = nil
    }
    
    // MARK: - Private Methods
    
    private func generateNewPrompt() {
        guard let numbers = dataManager?.numbers, !numbers.isEmpty else {
            return
        }
        
        let randomNumber = numbers.randomElement()!
        
        // Randomly choose between number->word or word->number
        if Bool.random() {
            gameState.currentPrompt = .numberToWord(randomNumber.value)
        } else {
            gameState.currentPrompt = .wordToNumber(randomNumber.bisaya)
        }
    }
}
