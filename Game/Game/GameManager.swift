import Foundation
import SpriteKit
import Combine
import SwiftUI

class GameManager: ObservableObject {
    static let shared = GameManager()

    @Published var gameState: GameState = .menu
    @Published var currentLevel: Int = 1
    @Published var currentAnimal: AnimalType = .panda
    @Published var shotsRemaining: Int = 3
    @Published var shotsUsed: Int = 0
    @Published var starsCollected: Int = 0
    @Published var totalStarsInLevel: Int = 0
    @Published var levelScore: Int = 0
    @Published var isPaused: Bool = false
    @Published var lastScoreInfo: HoopNode.ScoreInfo?
    @Published var abilityAvailable: Bool = true
    @Published var showTutorial: Bool = false
    @Published var levelResultMessage: String = ""
    @Published var comboCount: Int = 1

    var scoreManager = ScoreManager()
    var progressManager = GameProgressManager.shared

    private var cancellables = Set<AnyCancellable>()

    private init() {
        bindScoreUpdates()
    }

    private func bindScoreUpdates() {
        scoreManager.$currentScore
            .sink { [weak self] score in
                self?.levelScore = score
            }
            .store(in: &cancellables)
    }

    func navigateTo(_ state: GameState) {
        gameState = state
        SoundManager.shared.playSound("button_click")
    }

    func startGame(level: Int, animal: AnimalType? = nil) {
        currentLevel = level
        let levelData = LevelManager.shared.levelID(level)

        if let reqAnimal = levelData.requiredAnimal {
            currentAnimal = reqAnimal
        } else if let selAnimal = animal {
            currentAnimal = selAnimal
        } else {
            currentAnimal = progressManager.getSelectedAnimal()
        }

        shotsRemaining = levelData.parShots
        shotsUsed = 0
        starsCollected = 0
        totalStarsInLevel = levelData.stars.count
        isPaused = false
        abilityAvailable = true
        lastScoreInfo = nil
        comboCount = 1
        levelResultMessage = ""
        scoreManager.resetScore()

        gameState = .ready
        showTutorial = !progressManager.hasSeenTutorial && level == 1
    }

    func startLevelFromMenu(level: Int) {
        guard progressManager.isLevelUnlocked(level) else { return }
        let levelData = LevelManager.shared.levelID(level)

        if levelData.requiredAnimal != nil {
            startGame(level: level)
        } else {
            currentLevel = level
            gameState = .characterSelection
        }
    }

    func useShot() {
        shotsUsed += 1
        shotsRemaining = max(0, shotsRemaining - 1)
    }

    func collectStar() {
        starsCollected += 1
        scoreManager.addScore(50, type: .star, actionName: "Star")
        comboCount = scoreManager.comboMultiplier
        HapticManager.shared.starCollect()
    }

    func recordScore(info: HoopNode.ScoreInfo) {
        lastScoreInfo = info
        var actions: [String] = []

        scoreManager.addScore(100, type: .base)

        if info.isSwish {
            scoreManager.addScore(100, type: .swish, actionName: "Swish!")
            actions.append("SWISH")
            HapticManager.shared.swish()
        }
        if info.isBankShot {
            scoreManager.addScore(50, type: .bankShot, actionName: "Bank Shot")
            actions.append("BANK")
        }
        if info.isRimShot {
            scoreManager.addScore(20, type: .rimShot)
        }

        let starsEarned = calculateStarsEarned(info: info)
        saveLevelProgress(stars: starsEarned)

        if shotsUsed <= (LevelManager.shared.levelID(currentLevel).parShots - 1) {
            scoreManager.addBonus(points: 100, name: "Quick Shot")
        }

        if actions.count >= 2 {
            comboCount = actions.count
            scoreManager.addBonus(points: actions.count * 30, name: "Combo x\(actions.count)!")
        }

        levelResultMessage = info.isSwish ? "SWISH!" : (info.isBankShot ? "BANK SHOT!" : "SCORE!")
        gameState = .levelComplete
        HapticManager.shared.success()
        SoundManager.shared.playSound("level_complete")
    }

    private func calculateStarsEarned(info: HoopNode.ScoreInfo) -> Int {
        var stars = 1
        if starsCollected >= totalStarsInLevel && totalStarsInLevel > 0 {
            stars = 3
        } else if starsCollected >= max(1, totalStarsInLevel / 2) {
            stars = 2
        }
        if info.isSwish && stars < 3 && totalStarsInLevel == 0 {
            stars = min(stars + 1, 3)
        }
        return stars
    }

    func saveLevelProgress(stars: Int) {
        progressManager.setStars(stars, for: currentLevel)
        progressManager.setBestScore(scoreManager.currentScore, for: currentLevel)

        if currentLevel < 20 {
            progressManager.unlockLevel(currentLevel + 1)
        }
    }

    func handleShotFailed() {
        if shotsRemaining <= 0 {
            gameState = .failed
            HapticManager.shared.error()
            SoundManager.shared.playSound("fail")
        } else {
            gameState = .ready
            abilityAvailable = true
        }
    }

    func nextLevel() {
        let next = currentLevel + 1
        if next <= 20 && progressManager.isLevelUnlocked(next) {
            startGame(level: next)
        } else {
            gameState = .levelSelection
        }
    }

    func retryLevel() {
        startGame(level: currentLevel)
    }

    func exitToMenu() {
        gameState = .menu
    }

    func exitToLevelSelect() {
        gameState = .levelSelection
    }

    func pauseGame() {
        guard gameState == .ready || gameState == .aiming || gameState == .flying else { return }
        isPaused = true
        gameState = .paused
    }

    func resumeGame() {
        isPaused = false
        if shotsRemaining > 0 && lastScoreInfo == nil {
            gameState = .ready
        }
    }

    func restartLevel() {
        retryLevel()
    }

    func useAbility() {
        guard abilityAvailable else { return }
        abilityAvailable = false
    }

    func completeTutorial() {
        progressManager.hasSeenTutorial = true
        showTutorial = false
    }
}
