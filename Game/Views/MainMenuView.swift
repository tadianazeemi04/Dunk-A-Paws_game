import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var bounceOffset: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.75, blue: 0.95),
                    Color(red: 0.6, green: 0.85, blue: 0.98),
                    Color(red: 0.9, green: 0.95, blue: 1.0)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                VStack(spacing: 6) {
                    HStack(spacing: 0) {
                        ForEach(Array("DUNK".enumerated()), id: \.offset) { idx, ch in
                            Text(String(ch))
                                .font(.system(size: 50, weight: .black, design: .rounded))
                                .foregroundColor(letterColor(idx))
                                .offset(y: bounceOffset * (idx % 2 == 0 ? 1 : -1))
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 3)
                        }
                    }

                    HStack(spacing: 0) {
                        ForEach(Array("-A-PAWS".enumerated()), id: \.offset) { idx, ch in
                            Text(String(ch))
                                .font(.system(size: 50, weight: .black, design: .rounded))
                                .foregroundColor(letterColor(idx + 4))
                                .offset(y: bounceOffset * (idx % 2 == 0 ? -1 : 1))
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 3)
                        }
                    }
                    Text("🐾")
                        .font(.system(size: 24))
                        .offset(x: 140, y: -30)
                        .rotationEffect(.degrees(15))
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                        bounceOffset = 8
                    }
                }

                Text("SLINGSHOT HOOPS")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(5)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.orange)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                    )
                    .padding(.top, 4)

                Spacer().frame(height: 24)

                mascotView

                Spacer().frame(height: 28)

                VStack(spacing: 14) {
                    MenuButton(title: "PLAY", icon: "play.fill",
                               color: Color(red: 0.25, green: 0.8, blue: 0.45),
                               action: {
                                   gameManager.navigateTo(.levelSelection)
                               })
                    MenuButton(title: "CHARACTERS", icon: "pawprint.fill",
                               color: Color(red: 1.0, green: 0.55, blue: 0.35)) {
                        gameManager.navigateTo(.characterSelection)
                    }
                    MenuButton(title: "LEVELS", icon: "flag.fill",
                               color: Color(red: 0.35, green: 0.6, blue: 1.0)) {
                        gameManager.navigateTo(.levelSelection)
                    }
                    MenuButton(title: "SETTINGS", icon: "gearshape.fill",
                               color: Color(red: 0.55, green: 0.45, blue: 0.9)) {
                        gameManager.navigateTo(.settings)
                    }
                }
                .padding(.horizontal, 36)

                Spacer()

                Text("Version 1.0")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 12)
            }
            .padding()
        }
        .onAppear {
            SoundManager.shared.playMusic("menu")
        }
    }

    private func letterColor(_ idx: Int) -> Color {
        let colors: [Color] = [
            .orange, .red, .yellow, .green, .blue, .purple, .pink, .orange
        ]
        return colors[idx % colors.count]
    }

    private var mascotView: some View {
        HStack(spacing: -8) {
            ForEach(AnimalType.allCases.dropLast(), id: \.self) { animal in
                AnimalBadge(animal: animal, size: 70)
                    .rotationEffect(.degrees(animal == .panda ? -8 : (animal == .cat ? 0 : 8)))
                    .offset(y: animal == .cat ? -8 : 0)
            }
        }
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
    }
}

struct AnimalBadge: View {
    let animal: AnimalType
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [animal.bodyColor, animal.accentColor.opacity(0.3)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

            Text(animal.emoji)
                .font(.system(size: size * 0.55))
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var pressed: Bool = false

    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .tracking(1)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.75)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.45), lineWidth: 2)
            )
            .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 4)
            .scaleEffect(pressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
        .accessibilityLabel(title)
    }
}
