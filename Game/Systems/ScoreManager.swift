import Foundation
import Combine

class ScoreManager: ObservableObject {
    @Published var currentScore: Int = 0
    @Published var displayedScore: Int = 0
    @Published var comboMultiplier: Int = 1
    @Published var comboActions: [String] = []
    @Published var lastScoreType: ScoreType = .base
    @Published var bonusDetails: [String: Int] = [:]

    private var scoreAnimationTimer: Timer?
    private var pendingScore: Int = 0

    func resetScore() {
        currentScore = 0
        displayedScore = 0
        comboMultiplier = 1
        comboActions.removeAll()
        bonusDetails.removeAll()
        pendingScore = 0
        scoreAnimationTimer?.invalidate()
    }

    func addScore(_ points: Int, type: ScoreType = .base, actionName: String? = nil) {
        let multiplied = points * comboMultiplier
        currentScore += multiplied
        lastScoreType = type
        bonusDetails[typeName(type)] = (bonusDetails[typeName(type)] ?? 0) + multiplied

        if let action = actionName {
            comboActions.append(action)
            comboMultiplier = min(comboMultiplier + 1, 5)
        }

        animateScoreTo(currentScore)
    }

    func addBonus(points: Int, name: String) {
        addScore(points, type: .combo, actionName: name)
    }

    private func typeName(_ type: ScoreType) -> String {
        switch type {
        case .base: return "Basket"
        case .swish: return "Swish"
        case .bankShot: return "Bank Shot"
        case .rimShot: return "Rim Shot"
        case .star: return "Star"
        case .trampoline: return "Trampoline"
        case .longShot: return "Long Shot"
        case .fewShot: return "Few Shot"
        case .combo: return "Combo"
        }
    }

    private func animateScoreTo(_ target: Int) {
        scoreAnimationTimer?.invalidate()
        pendingScore = target

        scoreAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            let diff = self.pendingScore - self.displayedScore
            if diff == 0 {
                timer.invalidate()
                return
            }
            let step = max(1, abs(diff) / 15)
            if diff > 0 {
                self.displayedScore = min(self.displayedScore + step, self.pendingScore)
            } else {
                self.displayedScore = max(self.displayedScore - step, self.pendingScore)
            }
        }
    }

    func finalizeLevel(shotsUsed: Int, parShots: Int, starsCollected: Int, totalStars: Int) {
        if shotsUsed <= parShots {
            addBonus(points: 200 * (parShots - shotsUsed + 1), name: "Few Shots!")
        }
    }
}
