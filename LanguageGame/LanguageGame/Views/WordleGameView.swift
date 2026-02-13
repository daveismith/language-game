import SwiftUI

struct WordleGameView: View {
    @StateObject private var game = WordleGame()
    @EnvironmentObject var dataManager: DataManager
    
    @State private var gameState: WordleGameState = WordleGameState()
    @State private var inputLetter = ""
    @State private var showHint = false
    @State private var hintText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Game Title and Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wordle")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Guess letters to find the Bisaya word")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Display Word
                VStack(spacing: 12) {
                    Text(gameState.displayWord)
                        .font(.system(.largeTitle, design: .monospaced))
                        .fontWeight(.bold)
                        .tracking(8)
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            ForEach(gameState.wrongGuesses.sorted(), id: \.self) { letter in
                                Text(letter)
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.red.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        
                        if !gameState.wrongGuesses.isEmpty {
                            Text("Wrong: \(gameState.wrongGuesses.count)/6")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Game Status
                if gameState.isGameOver {
                    VStack(spacing: 12) {
                        if gameState.isGameWon {
                            Text("🎉 You Won!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        } else {
                            Text("Game Over")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        
                        Button(action: startNewGame) {
                            Text("New Game")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    // Input and Controls
                    VStack(spacing: 12) {
                        HStack {
                            TextField("Enter letter", text: $inputLetter)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.alphabet)
                            
                            Button(action: guessLetter) {
                                Text("Guess")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(inputLetter.isEmpty)
                        }
                        
                        Button(action: toggleHint) {
                            Text("💡 Hint (\(2 - gameState.hintsUsed))")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .disabled(gameState.hintsUsed >= 2)
                        
                        if showHint && !hintText.isEmpty {
                            Text(hintText)
                                .font(.caption)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Wordle")
            .onAppear {
                startNewGame()
            }
        }
    }
    
    private func startNewGame() {
        gameState = game.startNewGame()
        inputLetter = ""
        showHint = false
        hintText = ""
    }
    
    private func guessLetter() {
        guard !inputLetter.isEmpty else { return }
        gameState = game.guessLetter(inputLetter)
        inputLetter = ""
    }
    
    private func toggleHint() {
        if let hint = game.useHint() {
            hintText = hint
            showHint = true
        }
    }
}

#Preview {
    WordleGameView()
        .environmentObject(DataManager())
}
