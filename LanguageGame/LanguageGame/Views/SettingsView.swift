import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var dataManager: DataManager
    
    @State private var studentName = ""
    @State private var dataSourceURL = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // Student Profile Section
                Section(header: Text("Student Profile")) {
                    TextField("Student Name", text: $studentName)
                        .onAppear {
                            studentName = gameManager.playerProgress.studentName
                        }
                        .onChange(of: studentName) { newValue in
                            gameManager.updateStudentName(newValue)
                        }
                }
                
                // Data Source Section
                Section(
                    header: Text("Data Source"),
                    footer: Text("Enter a local path (/path/to/repo), file URL (file:///path), or GitHub URL (https://github.com/user/repo)")
                ) {
                    VStack(spacing: 12) {
                        TextField("Repository URL", text: $dataSourceURL)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .onAppear {
                                dataSourceURL = gameManager.playerProgress.dataSourceURL
                            }
                        
                        Button(action: updateDataSource) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Fetch from Repository")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        if !dataSourceURL.isEmpty {
                            Text("Current: \(dataSourceURL)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                
                // Content Status Section
                Section(header: Text("Content Status")) {
                    HStack {
                        Text("Vocabulary Words")
                        Spacer()
                        Text("\(dataManager.vocabulary.count)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Numbers")
                        Spacer()
                        Text("\(dataManager.numbers.count)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Games Played")
                        Spacer()
                        Text("\(gameManager.playerProgress.gamesPlayed.count)")
                            .fontWeight(.semibold)
                    }
                    
                    if let lastError = dataManager.lastError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(lastError)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Difficulty Preferences Section
                Section(header: Text("Game Difficulty")) {
                    Picker("Default Difficulty", selection: Binding(
                        get: { DifficultyLevel.medium },
                        set: { _ in }
                    )) {
                        Text("Easy").tag(DifficultyLevel.easy)
                        Text("Medium").tag(DifficultyLevel.medium)
                        Text("Hard").tag(DifficultyLevel.hard)
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("App")
                        Spacer()
                        Text("Bisaya Language Game")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Update Status", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func updateDataSource() {
        gameManager.updateDataSourceURL(dataSourceURL)
        
        Task {
            await dataManager.fetchDataFromRepository(url: dataSourceURL)
            
            DispatchQueue.main.async {
                if dataManager.lastError != nil {
                    alertMessage = dataManager.lastError ?? "Unknown error"
                } else {
                    alertMessage = "Data loaded successfully!\n\nVocabulary: \(dataManager.vocabulary.count)\nNumbers: \(dataManager.numbers.count)"
                }
                showAlert = true
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager())
        .environmentObject(GameManager())
}
