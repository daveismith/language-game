import SwiftUI

struct HangmanGameView: View {
    @StateObject private var game = HangmanGame()
    @EnvironmentObject var dataManager: DataManager
    
    @State private var gameState: HangmanGameState = HangmanGameState()
    @State private var inputLetter = ""
    @State private var showHint = false
    @State private var hintText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Game Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hangman")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Guess letters before the hangman is complete")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Hangman Stage Visualization
                VStack(spacing: 12) {
                    HangmanStageView(stage: gameState.hangmanStage)
                        .frame(height: 150)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Text("Remaining: \(6 - gameState.hangmanStage)")
                        .fontWeight(.semibold)
                        .foregroundColor(gameState.hangmanStage >= 5 ? .red : .primary)
                }
                
                // Display Word
                Text(gameState.displayWord)
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.bold)
                    .tracking(8)
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
                            Text("💡 Hint (\(1 - gameState.hintsUsed))")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .disabled(gameState.hintsUsed >= 1)
                        
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
            .navigationTitle("Hangman")
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

// MARK: - Hangman Stage Visualization

struct HangmanStageView: View {
    let stage: Int
    
    var body: some View {
        VStack {
            // Gallows
            HStack {
                VStack {
                    if stage >= 1 {
                        // Head
                        Circle()
                            .frame(width: 30, height: 30)
                            .offset(y: 10)
                    } else {
                        Spacer()
                            .frame(height: 40)
                    }
                    
                    if stage >= 2 {
                        // Body
                        Rectangle()
                            .frame(width: 3, height: 30)
                    }
                }
                .frame(width: 50)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

#Preview {
    HangmanGameView()
        .environmentObject(DataManager())
}
