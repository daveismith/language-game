import SwiftUI

struct NumberQuizGameView: View {
    @StateObject private var game = NumberQuizGame()
    @EnvironmentObject var dataManager: DataManager
    
    @State private var gameState: NumberQuizGameState = NumberQuizGameState()
    @State private var userInput = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Game Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Number Quiz")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Match Bisaya numbers to their values")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Question Prompt
                if let prompt = gameState.currentPrompt {
                    VStack(spacing: 20) {
                        Text("What is the answer?")
                            .font(.headline)
                        
                        switch prompt {
                        case .numberToWord(let number):
                            VStack(spacing: 12) {
                                Text("Number:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(number)")
                                    .font(.system(.largeTitle, design: .default))
                                    .fontWeight(.bold)
                            }
                            
                        case .wordToNumber(let bisaya):
                            VStack(spacing: 12) {
                                Text("Bisaya:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(bisaya)
                                    .font(.system(.title, design: .default))
                                    .fontWeight(.bold)
                            }
                        }
                        
                        // Input Field
                        VStack(spacing: 12) {
                            switch gameState.currentPrompt {
                            case .numberToWord(_):
                                TextField("Enter the Bisaya word", text: $userInput)
                                    .textFieldStyle(.roundedBorder)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.alphabet)
                                
                            case .wordToNumber(_):
                                TextField("Enter the number", text: $userInput)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                
                            case .none:
                                EmptyView()
                            }
                            
                            Button(action: submitAnswer) {
                                Text("Submit")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(userInput.isEmpty)
                        }
                        
                        // Answer Feedback
                        if let isCorrect = gameState.isAnswerCorrect {
                            VStack(spacing: 8) {
                                if isCorrect {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Correct!")
                                            .fontWeight(.semibold)
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                        Text("Incorrect")
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                Button(action: nextQuestion) {
                                    Text("Next Question")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                } else {
                    VStack {
                        Button(action: startNewGame) {
                            Text("Start Game")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                
                // Score Display
                let score = game.getScore()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Score: \(score.displayScore) (\(score.displayPercentage))")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Number Quiz")
            .onAppear {
                startNewGame()
            }
        }
    }
    
    private func startNewGame() {
        gameState = game.startNewGame()
        userInput = ""
    }
    
    private func submitAnswer() {
        gameState = game.submitAnswer(userInput)
    }
    
    private func nextQuestion() {
        game.nextQuestion()
        gameState = game.startNewGame()
        userInput = ""
    }
}

#Preview {
    NumberQuizGameView()
        .environmentObject(DataManager())
}
