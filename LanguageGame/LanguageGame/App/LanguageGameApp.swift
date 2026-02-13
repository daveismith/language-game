import SwiftUI

@main
struct LanguageGameApp: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(dataManager)
                .environmentObject(gameManager)
        }
    }
}
