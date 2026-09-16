import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var scene: GameScene?
    @State private var showObjective: Bool = true

    var levelID: Int

    var body: some View {
        ZStack {
            if let scene = scene {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .id(gameManager.currentLevel)
            }

            VStack {
                GameHUDView()
                Spacer()
                BottomHUDView()
            }
            .padding(.top, 8)
            .padding(.horizontal, 12)
            .padding(.bottom, 20)
            .allowsHitTesting(true)

            if showObjective && gameManager.gameState == .ready {
                ObjectiveOverlayView()
                    .transition(.opacity)
                    .animation(.easeInOut, value: showObjective)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { showObjective = false }
                        }
                    }
                    .onTapGesture {
                        withAnimation { showObjective = false }
                    }
            }

            if gameManager.gameState == .paused {
                PauseView()
                    .transition(.opacity)
            }

            if gameManager.gameState == .levelComplete {
                LevelCompleteView(onNext: {
                    scene?.resetAllStateForRetry()
                    showObjective = true
                }, onRetry: {
                    scene?.resetAllStateForRetry()
                    showObjective = true
                })
                .transition(.scale)
            }

            if gameManager.gameState == .failed {
                LevelFailedView(onRetry: {
                    scene?.resetAllStateForRetry()
                    showObjective = true
                })
                .transition(.opacity)
            }

            if gameManager.showTutorial {
                TutorialOverlayView { gameManager.completeTutorial() }
            }
        }
        .onAppear {
            setupScene()
        }
        .onChange(of: gameManager.currentLevel) { _, _ in
            setupScene()
            showObjective = true
        }
        .onChange(of: gameManager.isPaused) { _, paused in
            scene?.isPaused = paused
        }
    }

    private func setupScene() {
        let newScene = GameScene(size: CGSize(width: 390, height: 844))
        newScene.scaleMode = .aspectFill
        newScene.gameManager = gameManager

        let levelData = LevelManager.shared.levelID(levelID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            newScene.loadLevel(levelData)
        }
        self.scene = newScene
    }
}

struct GameHUDView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("LEVEL \(String(format: "%02d", gameManager.currentLevel))")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Button(action: {
                    gameManager.pauseGame()
                    SoundManager.shared.playSound("button_click")
                }) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .accessibilityLabel("Pause game")
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Text("SCORE")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                Text("\(gameManager.scoreManager.displayedScore)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    .monospacedDigit()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black.opacity(0.45))
            )

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 2) {
                    ForEach(0..<max(1, gameManager.totalStarsInLevel == 0 ? 3 : gameManager.totalStarsInLevel), id: \.self) { i in
                        Image(systemName: i < gameManager.starsCollected ? "star.fill" : "star")
                            .font(.system(size: 16))
                            .foregroundColor(i < gameManager.starsCollected ? .yellow : .white.opacity(0.5))
                    }
                }
            }
        }
    }
}

struct BottomHUDView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Text("SHOTS: \(gameManager.shotsRemaining)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.45))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                Spacer()

                if gameManager.gameState == .flying || gameManager.gameState == .aiming {
                    abilityButton
                } else {
                    Color.clear.frame(width: 120, height: 40)
                }
                Spacer()
            }
        }
    }

    private var abilityButton: some View {
        let animal = gameManager.currentAnimal
        let available = gameManager.abilityAvailable

        return Button(action: {
            // Cat ability handled in scene touches; panda/penguin passive
            SoundManager.shared.playSound("button_click")
        }) {
            HStack(spacing: 6) {
                Text(animal.emoji)
                    .font(.system(size: 16))
                Text(animal.shortAbilityName)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundColor(available ? .white : .white.opacity(0.4))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(available ? Color.orange : Color.gray.opacity(0.4))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(available ? 0.5 : 0.2), lineWidth: 1.5)
            )
            .scaleEffect(available ? 1.0 : 0.95)
            .animation(.easeInOut(duration: 0.2), value: available)
        }
        .accessibilityLabel("Use \(animal.name) ability")
    }
}

struct ObjectiveOverlayView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 100)
            VStack(spacing: 8) {
                Text("🎯 OBJECTIVE")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                Text(LevelManager.shared.levelID(gameManager.currentLevel).objective.description)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.black.opacity(0.65))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 15)

            Text("Tap to continue")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 6)

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct TutorialOverlayView: View {
    @EnvironmentObject var gameManager: GameManager
    var onComplete: () -> Void
    @State private var step: Int = 0

    private let steps = [
        (title: "PULL BACK", desc: "Drag the animal backward\nfrom the slingshot", emoji: "👆"),
        (title: "AIM", desc: "Watch the trajectory dots\nto predict your shot", emoji: "🎯"),
        (title: "RELEASE", desc: "Let go to launch!\nCollect stars along the way", emoji: "🚀")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 12) {
                Text(steps[step].emoji)
                    .font(.system(size: 60))
                Text(steps[step].title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(steps[step].desc)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.95), Color.red.opacity(0.85)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.35), radius: 20)
            .padding(.horizontal, 20)

            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Circle()
                        .fill(i == step ? Color.white : Color.white.opacity(0.35))
                        .frame(width: 9, height: 9)
                }
            }

            Button(action: {
                if step < steps.count - 1 {
                    withAnimation { step += 1 }
                } else {
                    onComplete()
                }
                SoundManager.shared.playSound("button_click")
            }) {
                Text(step < steps.count - 1 ? "NEXT" : "LET'S PLAY!")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8)
            }

            Spacer().frame(height: 80)
        }
        .background(Color.black.opacity(0.35).ignoresSafeArea())
        .transition(.opacity)
    }
}
