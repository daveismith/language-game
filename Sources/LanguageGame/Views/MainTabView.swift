import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        TabView {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Wordle Game Tab
            WordleGameView()
                .tabItem {
                    Label("Wordle", systemImage: "pencil.slash")
                }
            
            // Hangman Game Tab
            HangmanGameView()
                .tabItem {
                    Label("Hangman", systemImage: "square.and.pencil")
                }
            
            // Number Quiz Tab
            NumberQuizGameView()
                .tabItem {
                    Label("Numbers", systemImage: "123.rectangle.fill")
                }
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(DataManager())
        .environmentObject(GameManager())
}
