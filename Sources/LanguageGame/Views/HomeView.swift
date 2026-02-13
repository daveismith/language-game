import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome, \(gameManager.playerProgress.studentName)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Learn Bisaya through games")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Content Status
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Vocabulary")
                                .fontWeight(.semibold)
                            Text("\(dataManager.vocabulary.count) words")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(dataManager.vocabulary.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Numbers")
                                .fontWeight(.semibold)
                            Text("\(dataManager.numbers.count) numbers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(dataManager.numbers.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Game Statistics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Games")
                        .fontWeight(.semibold)
                    
                    if gameManager.playerProgress.gamesPlayed.isEmpty {
                        Text("No games played yet")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    } else {
                        ForEach(gameManager.playerProgress.gamesPlayed.suffix(5)) { stat in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(stat.gameType.capitalized)
                                        .fontWeight(.semibold)
                                    Text(stat.playedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(String(format: "%.0f%%", stat.score))
                                        .fontWeight(.bold)
                                    Text("\(stat.totalAttempts) attempts")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(DataManager())
        .environmentObject(GameManager())
}
