import SwiftUI

struct NumberQuizGameView: View {
    @StateObject private var game = NumberQuizGame()
    @EnvironmentObject var dataManager: DataManager
    
    @State private var userInput = ""
    @FocusState private var isInputFocused: Bool
    @State private var lastResult: (question: String, userAnswer: String, isCorrect: Bool, correctAnswer: String)?
    
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
                if let prompt = game.gameState.currentPrompt {
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
                            switch game.gameState.currentPrompt {
                            case .numberToWord(_):
                                TextField("Enter the Bisaya word", text: $userInput)
                                    .textFieldStyle(.roundedBorder)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .keyboardType(.alphabet)
                                    .focused($isInputFocused)
                                    .submitLabel(.done)
                                    .onSubmit { submitAnswer() }

                            case .wordToNumber(_):
                                TextField("Enter the number", text: $userInput)
                                    .textFieldStyle(.roundedBorder)
                                    .autocorrectionDisabled(true)
                                    .keyboardType(.numberPad)
                                    .focused($isInputFocused)
                                    .submitLabel(.done)
                                    .onSubmit { submitAnswer() }
                                
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
                        // Show last result (question, user's answer, and correct answer if wrong)
                        if let res = lastResult {
                            VStack(spacing: 8) {
                                HStack {
                                    if res.isCorrect {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Correct")
                                            .fontWeight(.semibold)
                                    } else {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                        Text("Incorrect")
                                            .fontWeight(.semibold)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Question: \(res.question)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Your answer: \(res.userAnswer)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if !res.isCorrect {
                                        Text("Correct answer: \(res.correctAnswer)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
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
                // focus the input when switching to this tab
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isInputFocused = true
                }
            }
        }
    }
    
    private func startNewGame() {
        _ = game.startNewGame()
        userInput = ""
    }
    
    private func submitAnswer() {
        // capture prompt before advancing
        guard let prompt = game.gameState.currentPrompt else { return }

        let state = game.submitAnswer(userInput)

        // compute question text and correct answer for display
        var questionText = ""
        var correctAnswer = ""
        switch prompt {
        case .numberToWord(let number):
            questionText = "Number: \(number)"
            if let matching = dataManager.numbers.first(where: { $0.value == number }) {
                correctAnswer = matching.bisaya
            }
        case .wordToNumber(let bisaya):
            questionText = "Bisaya: \(bisaya)"
            if let matching = dataManager.numbers.first(where: { $0.bisaya.lowercased() == bisaya.lowercased() }) {
                correctAnswer = String(matching.value)
            }
        }

        lastResult = (question: questionText, userAnswer: userInput, isCorrect: state.isAnswerCorrect ?? false, correctAnswer: correctAnswer)

        // advance immediately to a new prompt, clear input and refocus (after a short delay so the new TextField is present)
        game.nextQuestion()
        userInput = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            isInputFocused = true
        }
    }
    
    private func nextQuestion() {
        game.nextQuestion()
        userInput = ""
    }
}

#Preview {
    NumberQuizGameView()
        .environmentObject(DataManager())
}
