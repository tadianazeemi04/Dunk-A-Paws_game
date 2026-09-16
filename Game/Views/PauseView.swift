import SwiftUI

struct PauseView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 20) {
                Spacer().frame(height: 10)

                VStack(spacing: 2) {
                    Text("⏸️")
                        .font(.system(size: 50))
                    Text("PAUSED")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(3)
                }

                VStack(spacing: 13) {
                    PauseButton(title: "RESUME", icon: "play.fill",
                                color: Color(red: 0.25, green: 0.8, blue: 0.45)) {
                        gameManager.resumeGame()
                    }

                    PauseButton(title: "RESTART", icon: "arrow.counterclockwise",
                                color: Color.orange) {
                        gameManager.restartLevel()
                    }

                    PauseButton(title: "SETTINGS", icon: "gearshape.fill",
                                color: Color(red: 0.55, green: 0.45, blue: 0.9)) {
                        gameManager.gameState = .settings
                    }

                    PauseButton(title: "EXIT LEVEL", icon: "rectangle.portrait.and.arrow.right",
                                color: Color(red: 0.9, green: 0.35, blue: 0.35)) {
                        gameManager.exitToLevelSelect()
                    }
                }
                .padding(.horizontal, 28)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.25, blue: 0.4),
                                     Color(red: 0.12, green: 0.15, blue: 0.3)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 24)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
            .zIndex(10)
        }
    }
}

struct PauseButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            SoundManager.shared.playSound("button_click")
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .opacity(0.6)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LevelCompleteView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var starsRevealed: Int = 0
    @State private var showDetails: Bool = false
    var onNext: () -> Void
    var onRetry: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer().frame(height: 10)

                Text(gameManager.levelResultMessage.isEmpty ? "LEVEL COMPLETE!" : gameManager.levelResultMessage)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                VStack(spacing: 8) {
                    HStack(spacing: 14) {
                        ForEach(0..<3, id: \.self) { i in
                            ZStack {
                                Image(systemName: "star")
                                    .font(.system(size: 52, weight: .bold))
                                    .foregroundColor(.white.opacity(0.25))

                                Image(systemName: "star.fill")
                                    .font(.system(size: 52, weight: .bold))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .yellow.opacity(0.7), radius: 6)
                                    .scaleEffect(starsRevealed > i ? 1.0 : 0.001)
                                    .opacity(starsRevealed > i ? 1 : 0)
                                    .animation(
                                        .interpolatingSpring(stiffness: 200, damping: 12)
                                        .delay(Double(i) * 0.25),
                                        value: starsRevealed
                                    )
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .onAppear {
                    let earned = max(1, GameProgressManager.shared.getStars(for: gameManager.currentLevel))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation { starsRevealed = earned }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        withAnimation { showDetails = true }
                    }
                }

                if showDetails {
                    VStack(spacing: 10) {
                        HStack {
                            Text("SCORE")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(gameManager.scoreManager.currentScore)")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(.yellow)
                                .monospacedDigit()
                        }

                        HStack {
                            Text("BEST")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(GameProgressManager.shared.getBestScore(for: gameManager.currentLevel))")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                                .monospacedDigit()
                        }

                        HStack {
                            Text("SHOTS USED")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(gameManager.shotsUsed)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }

                        if let info = gameManager.lastScoreInfo {
                            if info.isSwish {
                                bonusRow(title: "✨ SWISH BONUS", points: "+100", color: .yellow)
                            }
                            if info.isBankShot {
                                bonusRow(title: "🏦 BANK SHOT", points: "+50", color: .orange)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 14)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                HStack(spacing: 12) {
                    if gameManager.currentLevel < 20 &&
                        GameProgressManager.shared.isLevelUnlocked(gameManager.currentLevel + 1) {
                        CompleteButton(
                            title: "NEXT",
                            icon: "arrow.right",
                            color: Color(red: 0.25, green: 0.8, blue: 0.45)
                        ) {
                            onNext()
                            gameManager.nextLevel()
                        }
                    }

                    CompleteButton(
                        title: "RETRY",
                        icon: "arrow.counterclockwise",
                        color: Color.orange
                    ) {
                        onRetry()
                        gameManager.retryLevel()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, showDetails ? 4 : 10)

                Button(action: {
                    gameManager.exitToLevelSelect()
                }) {
                    Text("Level Select")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .underline()
                }
                .padding(.bottom, 14)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 22)
            .background(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.7, blue: 0.48),
                                Color(red: 0.12, green: 0.4, blue: 0.7)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 2.5)
            )
            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 18)
            .transition(.scale(scale: 0.88).combined(with: .opacity))
            .zIndex(10)
        }
    }

    private func bonusRow(title: String, points: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Spacer()
            Text(points)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

struct CompleteButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var pressed: Bool = false

    var body: some View {
        Button(action: {
            HapticManager.shared.mediumImpact()
            SoundManager.shared.playSound("button_click")
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                Capsule()
                    .fill(color)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.55), lineWidth: 2)
            )
            .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 4)
            .scaleEffect(pressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}

struct LevelFailedView: View {
    @EnvironmentObject var gameManager: GameManager
    var onRetry: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Text("😿")
                    .font(.system(size: 60))
                Text("OUT OF SHOTS!")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(1)

                Text("You used all \(LevelManager.shared.levelID(gameManager.currentLevel).parShots) shots.\nDon't give up! Try again.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 14)

                if gameManager.starsCollected > 0 {
                    HStack(spacing: 3) {
                        Text("Stars collected:")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                        ForEach(0..<gameManager.totalStarsInLevel, id: \.self) { i in
                            Image(systemName: i < gameManager.starsCollected ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundColor(i < gameManager.starsCollected ? .yellow : .white.opacity(0.4))
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Capsule().fill(Color.white.opacity(0.15)))
                }

                VStack(spacing: 12) {
                    CompleteButton(title: "RETRY", icon: "arrow.counterclockwise",
                                color: Color.orange) {
                        onRetry()
                        gameManager.retryLevel()
                    }

                    CompleteButton(title: "LEVEL SELECT", icon: "list.bullet",
                                color: Color(red: 0.4, green: 0.6, blue: 1.0)) {
                        gameManager.exitToLevelSelect()
                    }

                    CompleteButton(title: "MAIN MENU", icon: "house.fill",
                                color: Color(red: 0.55, green: 0.45, blue: 0.9)) {
                        gameManager.exitToMenu()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 26)
            .background(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.85, green: 0.3, blue: 0.35),
                                Color(red: 0.55, green: 0.15, blue: 0.3)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 2.5)
            )
            .shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
            .zIndex(10)
        }
    }
}
