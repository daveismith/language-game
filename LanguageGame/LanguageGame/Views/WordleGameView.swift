import SwiftUI

struct WordleGameView: View {
    @StateObject private var game = WordleGame()
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var gameManager: GameManager
    
    // input is now handled by on-screen keyboard and stored into the game's current guess row
    @State private var showHint = false
    @State private var hintText = ""
    @State private var showGameOver = false
    @State private var validationMessage: String?

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
                    // Input and Controls: on-screen keyboard
                    VStack(spacing: 12) {
                        if let validation = validationMessage {
                            Text(validation)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }

                        // keyboard rows
                        let topRow = "qwertyuiop"
                        let midRow = "asdfghjkl"
                        let botRow = "zxcvbnm"

                        // compute aggregated letter states from past guesses
                        let keyStates = aggregateKeyStates()

                        HStack(spacing: 6) {
                            Spacer(minLength: 0)
                            ForEach(Array(topRow), id: \.self) { ch in
                                let s = keyStates[String(ch)] ?? .unknown
                                Button(action: { appendLetter(String(ch)) }) {
                                    Text(String(ch).uppercased())
                                        .fontWeight(.semibold)
                                        .frame(width: 34, height: 44)
                                        .background(backgroundColor(for: s))
                                        .cornerRadius(6)
                                }
                                .disabled(game.gameState.isGameOver)
                            }
                            Spacer(minLength: 0)
                        }

                        HStack(spacing: 6) {
                            Spacer(minLength: 0)
                            ForEach(Array(midRow), id: \.self) { ch in
                                let s = keyStates[String(ch)] ?? .unknown
                                Button(action: { appendLetter(String(ch)) }) {
                                    Text(String(ch).uppercased())
                                        .fontWeight(.semibold)
                                        .frame(width: 34, height: 44)
                                        .background(backgroundColor(for: s))
                                        .cornerRadius(6)
                                }
                                .disabled(game.gameState.isGameOver)
                            }
                            Spacer(minLength: 0)
                        }

                        HStack(spacing: 6) {
                            Spacer(minLength: 0)
                            // Enter to the left of Z
                            Button(action: enterPressed) {
                                Text("Enter")
                                    .fontWeight(.semibold)
                                    .frame(width: 56, height: 44)
                                    .background(Color(.systemGray4))
                                    .cornerRadius(6)
                            }
                            .disabled(game.gameState.isGameOver)

                            ForEach(Array(botRow), id: \.self) { ch in
                                let s = keyStates[String(ch)] ?? .unknown
                                Button(action: { appendLetter(String(ch)) }) {
                                    Text(String(ch).uppercased())
                                        .fontWeight(.semibold)
                                        .frame(width: 34, height: 44)
                                        .background(backgroundColor(for: s))
                                        .cornerRadius(6)
                                }
                                .disabled(game.gameState.isGameOver)
                            }

                            // Backspace to the right of M
                            Button(action: backspaceLetter) {
                                Text("⌫")
                                    .fontWeight(.semibold)
                                    .frame(width: 56, height: 44)
                                    .background(Color(.systemGray4))
                                    .cornerRadius(6)
                            }
                            .disabled(game.gameState.isGameOver)

                            Spacer(minLength: 0)
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
        showHint = false
        hintText = ""
        _ = game.startNewGame()
    }
    
    private func guessLetter() {
        enterPressed()
    }
    

    private func currentAttemptIndex() -> Int {
        return game.gameState.currentAttempt
    }

    private func currentGuessString() -> String {
        let attempt = currentAttemptIndex()
        guard game.gameState.guesses.indices.contains(attempt) else { return "" }
        return game.gameState.guesses[attempt].joined()
    }

    private func updateLetter(at index: Int, with letter: String) {
        var gs = game.gameState
        let attempt = currentAttemptIndex()
        guard gs.guesses.indices.contains(attempt), gs.guesses[attempt].indices.contains(index) else { return }
        gs.guesses[attempt][index] = letter.lowercased()
        game.gameState = gs
    }

    private func appendLetter(_ letter: String) {
        var gs = game.gameState
        let attempt = currentAttemptIndex()
        guard !gs.isGameOver else { return }
        let length = gs.wordLength
        guard gs.guesses.indices.contains(attempt) else { return }
        if let idx = gs.guesses[attempt].firstIndex(where: { $0.isEmpty }) {
            gs.guesses[attempt][idx] = letter.lowercased()
            game.gameState = gs
        }
    }

    private func backspaceLetter() {
        var gs = game.gameState
        let attempt = currentAttemptIndex()
        guard gs.guesses.indices.contains(attempt) else { return }
        if let lastIdx = gs.guesses[attempt].lastIndex(where: { !$0.isEmpty }) {
            gs.guesses[attempt][lastIdx] = ""
            game.gameState = gs
        }
    }

    private func enterPressed() {
        let cleaned = currentGuessString().trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let expectedLen = max(1, game.gameState.wordLength)
        guard cleaned.count == expectedLen else {
            validationMessage = "Guess must be \(expectedLen) letters"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { validationMessage = nil }
            return
        }

        // Validate against the full vocabulary (not filtered by difficulty)
        let allWords = dataManager.vocabulary.map { $0.word.lowercased() }
        guard allWords.contains(cleaned) else {
            validationMessage = "Word not in list"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { validationMessage = nil }
            return
        }

        _ = game.guessWord(cleaned)
        // clear any transient state (hints)
        showHint = false
        hintText = ""
        validationMessage = nil
    }

    // Aggregate per-letter state from completed guess results.
    // Priority: correct > present > absent > unknown
    private func aggregateKeyStates() -> [String: LetterResult] {
        var map: [String: LetterResult] = [:]
        for r in 0..<game.gameState.results.count {
            let row = game.gameState.results[r]
            // only consider rows that have been submitted (attempt < currentAttempt or if isGameOver)
            if r >= game.gameState.currentAttempt && !game.gameState.isGameOver { break }
            for i in 0..<row.count {
                let res = row[i]
                // if the corresponding guessed letter exists, use it
                if game.gameState.guesses.indices.contains(r) && game.gameState.guesses[r].indices.contains(i) {
                    let letter = game.gameState.guesses[r][i].lowercased()
                    guard !letter.isEmpty else { continue }
                    let prev = map[letter] ?? .unknown
                    switch (prev, res) {
                    case (.correct, _): continue
                    case (_, .correct): map[letter] = .correct
                    case (.present, _): continue
                    case (_, .present): map[letter] = .present
                    case (.absent, _): continue
                    case (_, .absent): map[letter] = .absent
                    default: break
                    }
                }
            }
        }
        return map
    }

    private func backgroundColor(for state: LetterResult) -> Color {
        switch state {
        case .unknown: return Color(.systemGray5)
        case .absent: return Color(.systemGray3)
        case .present: return Color.yellow.opacity(0.8)
        case .correct: return Color.green.opacity(0.8)
        }
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
