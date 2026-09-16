import SwiftUI

struct CharacterSelectView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var progressManager: GameProgressManager
    @State private var selectedAnimal: AnimalType

    init() {
        let stored = GameProgressManager.shared.getSelectedAnimal()
        _selectedAnimal = State(initialValue: stored)
    }

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.75, blue: 0.8),
                    Color(red: 0.8, green: 0.7, blue: 1.0),
                    Color(red: 0.7, green: 0.9, blue: 1.0)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                    .padding(.top, 4)
                    .padding(.horizontal, 18)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        ForEach(AnimalType.allCases) { animal in
                            CharacterCard(
                                animal: animal,
                                isSelected: selectedAnimal == animal,
                                isRequired: isRequired(animal),
                                isSelectable: canSelect(animal)
                            ) {
                                if canSelect(animal) {
                                    selectedAnimal = animal
                                    HapticManager.shared.selection()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 120)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            VStack {
                Spacer()
                bottomButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
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
            .accessibilityLabel("Back")

            Spacer()

            Text("CHOOSE ANIMAL")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .tracking(1.5)
                .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 2)

            Spacer()

            Color.clear
                .frame(width: 42, height: 42)
        }
    }

    private var bottomButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                progressManager.setSelectedAnimal(selectedAnimal)
                HapticManager.shared.success()
                if gameManager.currentLevel > 0 {
                    gameManager.startGame(level: gameManager.currentLevel, animal: selectedAnimal)
                } else {
                    gameManager.navigateTo(.levelSelection)
                }
            }) {
                HStack(spacing: 10) {
                    Text(selectedAnimal.emoji)
                        .font(.system(size: 22))
                    Text("PLAY AS \(selectedAnimal.name.uppercased())")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.6), lineWidth: 2.5)
                )
                .shadow(color: .orange.opacity(0.5), radius: 12, x: 0, y: 6)
            }
        }
    }

    private func isRequired(_ animal: AnimalType) -> Bool {
        guard gameManager.currentLevel > 0 else { return false }
        let level = LevelManager.shared.levelID(gameManager.currentLevel)
        return level.requiredAnimal == animal
    }

    private func canSelect(_ animal: AnimalType) -> Bool {
        if gameManager.currentLevel > 0 {
            let level = LevelManager.shared.levelID(gameManager.currentLevel)
            if let req = level.requiredAnimal {
                return req == animal
            }
        }
        return true
    }
}

struct CharacterCard: View {
    let animal: AnimalType
    let isSelected: Bool
    let isRequired: Bool
    let isSelectable: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [animal.bodyColor, animal.accentColor.opacity(0.4)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 92, height: 92)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.white : Color.white.opacity(0.6), lineWidth: isSelected ? 5 : 2)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)

                    Text(animal.emoji)
                        .font(.system(size: 50))

                    if isRequired {
                        VStack {
                            HStack {
                                Spacer()
                                Text("⭐")
                                    .font(.system(size: 16))
                                    .padding(4)
                                    .background(Circle().fill(Color.white))
                            }
                            Spacer()
                        }
                        .frame(width: 92, height: 92)
                    }
                }

                VStack(spacing: 3) {
                    Text(animal.name.uppercased())
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(animal.tagline)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))

                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text(animal.abilityName)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.35))
                    )
                }

                Text(animal.description)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                    .frame(height: 30)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                isSelected ? Color.orange.opacity(0.85) : Color.white.opacity(0.25),
                                isSelected ? Color.red.opacity(0.75) : Color.black.opacity(0.15)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isSelected ? Color.white : Color.white.opacity(0.35), lineWidth: isSelected ? 3 : 1.5)
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isSelectable ? 1.0 : 0.45)
        .disabled(!isSelectable)
    }
}
