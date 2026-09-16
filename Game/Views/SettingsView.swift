import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var progressManager: GameProgressManager
    @State private var showResetConfirm: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    Color(red: 0.42, green: 0.32, blue: 0.72),
                    Color(red: 0.62, green: 0.44, blue: 0.82),
                    Color(red: 0.82, green: 0.68, blue: 0.92)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                headerView
                    .padding(.horizontal, 18)
                    .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        sectionTitle("Audio & Feedback")

                        ToggleRow(
                            icon: "speaker.wave.2.fill",
                            title: "Sound Effects",
                            isOn: Binding(
                                get: { progressManager.soundEnabled },
                                set: { progressManager.soundEnabled = $0 }
                            )
                        )

                        ToggleRow(
                            icon: "music.note",
                            title: "Background Music",
                            isOn: Binding(
                                get: { progressManager.musicEnabled },
                                set: {
                                    progressManager.musicEnabled = $0
                                    if !$0 { SoundManager.shared.stopMusic() }
                                    else if gameManager.gameState == .menu {
                                        SoundManager.shared.playMusic("menu")
                                    }
                                }
                            )
                        )

                        ToggleRow(
                            icon: "hand.tap.fill",
                            title: "Haptic Feedback",
                            isOn: Binding(
                                get: { progressManager.hapticsEnabled },
                                set: { progressManager.hapticsEnabled = $0 }
                            )
                        )

                        sectionTitle("Game Progress")

                        InfoRow(icon: "flag.fill",
                                title: "Levels Unlocked",
                                value: "\(progressManager.progress.highestUnlockedLevel)/20")

                        var totalStars: Int {
                            (1...20).reduce(0) { $0 + progressManager.getStars(for: $1) }
                        }
                        InfoRow(icon: "star.fill",
                                title: "Total Stars",
                                value: "\(totalStars)/60",
                                valueColor: .yellow)

                        InfoRow(icon: "pawprint.fill",
                                title: "Selected Animal",
                                value: progressManager.getSelectedAnimal().emoji + " " + progressManager.getSelectedAnimal().name)

                        sectionTitle("Danger Zone")

                        Button(action: {
                            withAnimation { showResetConfirm = true }
                            HapticManager.shared.warning()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .bold))
                                Text("RESET ALL PROGRESS")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.opacity(0.85))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .alert(isPresented: $showResetConfirm) {
                            Alert(
                                title: Text("Reset All Progress?"),
                                message: Text("This will permanently delete all your levels, stars, scores, and preferences. This cannot be undone!"),
                                primaryButton: .destructive(Text("Reset Everything")) {
                                    progressManager.resetProgress()
                                    HapticManager.shared.error()
                                },
                                secondaryButton: .cancel(Text("Keep Progress"))
                            )
                        }

                        sectionTitle("About")
                        aboutCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    .padding(.bottom, 32)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var headerView: some View {
        HStack {
            Button(action: {
                HapticManager.shared.lightImpact()
                if gameManager.gameState == .settings {
                    if gameManager.currentLevel > 0 {
                        gameManager.gameState = .paused
                    } else {
                        gameManager.exitToMenu()
                    }
                } else {
                    gameManager.exitToMenu()
                }
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
            .accessibilityLabel("Back")

            Spacer()

            Text("SETTINGS")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .tracking(1.5)
                .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 2)

            Spacer()

            Color.clear
                .frame(width: 42, height: 42)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .tracking(1)
            Spacer()
        }
        .padding(.top, 10)
    }

    private var aboutCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Text("🐼🐱🐧")
                    .font(.system(size: 30))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dunk-A-Paws")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Slingshot Hoops v1.0")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }

            Divider().background(Color.white.opacity(0.2))

            Text("Cute animals become basketballs, slingshots become launchers, and every basket becomes a trick shot! 🎯")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
        )
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )

            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: Binding(
                get: { isOn },
                set: { newValue in
                    isOn = newValue
                    HapticManager.shared.selection()
                    SoundManager.shared.playSound("button_click")
                }
            ))
            .labelsHidden()
            .tint(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
        )
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.yellow)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )

            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(valueColor)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
        )
    }
}
