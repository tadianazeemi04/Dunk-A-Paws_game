import Foundation
import SwiftUI
import Combine

class GameProgressManager: ObservableObject {
    static let shared = GameProgressManager()

    @Published var progress: GameProgress {
        didSet {
            save()
        }
    }

    private let defaultsKey = "DunkAPaws_GameProgress"

    private init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode(GameProgress.self, from: data) {
            self.progress = decoded
        } else {
            self.progress = GameProgress()
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }

    func getSelectedAnimal() -> AnimalType {
        AnimalType(rawValue: progress.selectedCharacter) ?? .cat
    }

    func setSelectedAnimal(_ animal: AnimalType) {
        progress.selectedCharacter = animal.rawValue
    }

    func isLevelUnlocked(_ level: Int) -> Bool {
        level <= progress.highestUnlockedLevel
    }

    func unlockLevel(_ level: Int) {
        if level > progress.highestUnlockedLevel {
            progress.highestUnlockedLevel = level
        }
    }

    func getStars(for level: Int) -> Int {
        progress.levelStars[level] ?? 0
    }

    func setStars(_ stars: Int, for level: Int) {
        if stars > getStars(for: level) {
            progress.levelStars[level] = stars
        }
    }

    func getBestScore(for level: Int) -> Int {
        progress.bestScores[level] ?? 0
    }

    func setBestScore(_ score: Int, for level: Int) {
        if score > getBestScore(for: level) {
            progress.bestScores[level] = score
        }
    }

    func resetProgress() {
        progress = GameProgress()
    }

    var soundEnabled: Bool {
        get { progress.soundEnabled }
        set { progress.soundEnabled = newValue }
    }

    var musicEnabled: Bool {
        get { progress.musicEnabled }
        set { progress.musicEnabled = newValue }
    }

    var hapticsEnabled: Bool {
        get { progress.hapticsEnabled }
        set { progress.hapticsEnabled = newValue }
    }

    var hasSeenTutorial: Bool {
        get { progress.hasSeenTutorial }
        set { progress.hasSeenTutorial = newValue }
    }
}
