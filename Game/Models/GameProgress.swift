import Foundation

struct GameProgress: Codable {
    var selectedCharacter: String = AnimalType.cat.rawValue
    var highestUnlockedLevel: Int = 1
    var levelStars: [Int: Int] = [:]
    var bestScores: [Int: Int] = [:]
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var hasSeenTutorial: Bool = false
}
