import SwiftUI
import SpriteKit
import Combine

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var progressManager: GameProgressManager

    var body: some View {
        Group {
            switch gameManager.gameState {
            case .menu:
                MainMenuView()
                    .environmentObject(gameManager)
                    .environmentObject(progressManager)
                    .transition(.opacity)

            case .characterSelection:
                CharacterSelectView()
                    .environmentObject(gameManager)
                    .environmentObject(progressManager)
                    .transition(.move(edge: .trailing))

            case .levelSelection:
                LevelSelectView()
                    .environmentObject(gameManager)
                    .environmentObject(progressManager)
                    .transition(.move(edge: .trailing))

            case .settings:
                SettingsView()
                    .environmentObject(gameManager)
                    .environmentObject(progressManager)
                    .transition(.move(edge: .bottom))

            case .ready, .aiming, .flying, .paused, .scored, .failed, .levelComplete:
                GameView(levelID: gameManager.currentLevel)
                    .environmentObject(gameManager)
                    .environmentObject(progressManager)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameManager.gameState)
        .onAppear {
            SoundManager.shared.playMusic("menu")
        }
        .onChange(of: gameManager.gameState) { _, newState in
            switch newState {
            case .menu, .levelSelection, .characterSelection, .settings:
                SoundManager.shared.playMusic("menu")
            case .ready, .aiming, .flying:
                SoundManager.shared.playMusic("gameplay")
            case .levelComplete:
                SoundManager.shared.playMusic("victory")
            default:
                break
            }
        }
        .preferredColorScheme(.light)
        .statusBarHidden(true)
    }
}
