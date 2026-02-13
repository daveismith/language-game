import SwiftUI

struct WordleGameView: View {
    @StateObject private var game = WordleGame()
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var gameManager: GameManager
    
    @State private var inputLetter = ""
    @State private var showHint = false
    @State private var hintText = ""
    @State private var showGameOver = false

    // no local grid helper: use gameState.guesses and results
    
    var body: some View {
        let rows = game.gameState.guesses
        let resultRows = game.gameState.results
        NavigationStack {
            VStack(spacing: 20) {
                // Game Title
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
                Group {
                    if !rows.isEmpty {
                        WordGridView(rows: rows, results: resultRows)
                    } else {
                        // Placeholder while loading or before a word is selected
                        VStack(spacing: 6) {
                            if dataManager.vocabulary.isEmpty {
                                Text("Loading words...")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Preparing puzzle...")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 80)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Game Status
                if game.gameState.isGameOver {
                    VStack(spacing: 12) {
                        if game.gameState.isGameWon {
                            VStack(spacing: 6) {
                                Text("🎉 Correct!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)

                                if let solution = game.revealSolution() {
                                    Text("The word was: \(solution)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            Text("Game Over")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            
                            Text("Better luck next time!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
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
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                } else {
                    // Input and Controls
                    VStack(spacing: 12) {
                        HStack {
                            TextField("Enter guess", text: $inputLetter)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.alphabet)
                                .onChange(of: inputLetter) { oldValue, newValue in
                                    // keep lowercase and trim to expected length
                                    inputLetter = newValue.lowercased()
                                    let maxLen = max(1, game.gameState.wordLength)
                                    if inputLetter.count > maxLen {
                                        inputLetter = String(inputLetter.prefix(maxLen))
                                    }
                                }

                            Button(action: {
                                // submit full-word guess
                                _ = game.guessWord(inputLetter)
                                inputLetter = ""
                            }) {
                                Text("Guess")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(inputLetter.count != game.gameState.wordLength)
                        }
                        
                        Button(action: toggleHint) {
                            Text("💡 Hint (\(2 - game.gameState.hintsUsed))")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .disabled(game.gameState.hintsUsed >= 2)
                        
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
                // Attach the environment DataManager to the game instance so it uses the same data
                game.attachDataManager(dataManager)
                // Start a new game whenever the view appears (will no-op if no words)
                startNewGame()
            }
            .onReceive(dataManager.$vocabulary) { newValue in
                // When vocabulary loads or changes, attach and start a new game
                if !newValue.isEmpty {
                    game.attachDataManager(dataManager)
                    startNewGame()
                }
            }
        }
    }
    
    private func startNewGame() {
        inputLetter = ""
        showHint = false
        hintText = ""
        _ = game.startNewGame()
    }
    
    private func guessLetter() {
        guard !inputLetter.isEmpty else { return }
        _ = game.guessWord(inputLetter)
        inputLetter = ""
        showHint = false
        hintText = ""
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
        .environmentObject(GameManager())
}

// Small helper view to render the grid. Splitting this out keeps the main view simple
fileprivate struct WordGridView: View {
    let rows: [[String]]
    let results: [[LetterResult]]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack {
                    Spacer(minLength: 0)
                    HStack(spacing: 6) {
                        ForEach(0..<rows[rowIndex].count, id: \.self) { col in
                            let cell = rows[rowIndex][col]
                            let state = results.indices.contains(rowIndex) && results[rowIndex].indices.contains(col) ? results[rowIndex][col] : .unknown
                            Text(cell.isEmpty ? "" : cell.uppercased())
                                .font(.system(.title2, design: .monospaced))
                                .fontWeight(.bold)
                                .frame(width: 48, height: 48)
                                .background(backgroundColor(for: state))
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func backgroundColor(for state: LetterResult) -> Color {
        switch state {
        case .unknown: return Color(.systemGray6)
        case .absent: return Color(.systemGray4)
        case .present: return Color.yellow.opacity(0.8)
        case .correct: return Color.green.opacity(0.8)
        }
    }
}
