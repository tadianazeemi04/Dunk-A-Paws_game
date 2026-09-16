import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var progressManager: GameProgressManager

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    Color(red: 0.38, green: 0.72, blue: 0.98),
                    Color(red: 0.65, green: 0.86, blue: 0.98),
                    Color(red: 0.92, green: 0.96, blue: 1.0)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                headerView
                    .padding(.horizontal, 18)
                    .padding(.top, 4)

                progressSummaryView
                    .padding(.horizontal, 18)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(LevelManager.shared.allLevels(), id: \.id) { level in
                            LevelGridCell(
                                level: level.id,
                                stars: progressManager.getStars(for: level.id),
                                unlocked: progressManager.isLevelUnlocked(level.id),
                                bestScore: progressManager.getBestScore(for: level.id)
                            ) {
                                if progressManager.isLevelUnlocked(level.id) {
                                    HapticManager.shared.selection()
                                    gameManager.startLevelFromMenu(level: level.id)
                                } else {
                                    HapticManager.shared.warning()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    .padding(.bottom, 28)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            SoundManager.shared.playMusic("menu")
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: {
                HapticManager.shared.lightImpact()
                gameManager.exitToMenu()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 42, height: 42)
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 42, height: 42)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .accessibilityLabel("Back to menu")

            Spacer()

            Text("SELECT LEVEL")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .tracking(1.5)
                .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 2)

            Spacer()

            Color.clear
                .frame(width: 42, height: 42)
        }
    }

    private var progressSummaryView: some View {
        var totalStars = 0
        var unlockedLevels = 0
        for i in 1...20 {
            totalStars += progressManager.getStars(for: i)
            if progressManager.isLevelUnlocked(i) { unlockedLevels += 1 }
        }

        return HStack(spacing: 12) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 32, height: 32)
                    Image(systemName: "star.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(totalStars) / 60")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Stars Collected")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.88))
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 0.95, green: 0.45, blue: 0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
            )
            .shadow(color: Color.orange.opacity(0.25), radius: 5, x: 0, y: 2)

            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 32, height: 32)
                    Image(systemName: "flag.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(unlockedLevels) / 20")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Levels Unlocked")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.88))
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.28, green: 0.58, blue: 0.98), Color(red: 0.18, green: 0.45, blue: 0.88)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
            )
            .shadow(color: Color.blue.opacity(0.25), radius: 5, x: 0, y: 2)
        }
    }
}

struct LevelGridCell: View {
    let level: Int
    let stars: Int
    let unlocked: Bool
    let bestScore: Int
    let action: () -> Void

    @State private var pressed: Bool = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text("\(level)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(unlocked ? .white : .white.opacity(0.65))

                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(i < stars ? .yellow : (unlocked ? .white.opacity(0.55) : .white.opacity(0.3)))
                    }
                }

                if unlocked && bestScore > 0 {
                    Text("🏆 \(bestScore)")
                        .font(.system(size: 8.5, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                } else if !unlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("PLAY")
                        .font(.system(size: 8, weight: .heavy, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: unlocked
                                ? [themeColor, themeColor.opacity(0.75)]
                                : [Color.gray.opacity(0.5), Color.gray.opacity(0.4)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(unlocked ? Color.white.opacity(0.55) : Color.white.opacity(0.25), lineWidth: 1.5)
            )
            .shadow(color: unlocked ? themeColor.opacity(0.4) : .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .opacity(unlocked ? 1.0 : 0.75)
            .scaleEffect(pressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if unlocked { pressed = true } }
                .onEnded { _ in pressed = false }
        )
    }

    private var themeColor: Color {
        switch level {
        case 1...5: return Color(red: 0.35, green: 0.78, blue: 0.45)
        case 6...10: return Color(red: 1.0, green: 0.52, blue: 0.72)
        case 11...15: return Color(red: 0.35, green: 0.72, blue: 0.92)
        case 16...20: return Color(red: 0.55, green: 0.48, blue: 0.85)
        default: return .gray
        }
    }
}
