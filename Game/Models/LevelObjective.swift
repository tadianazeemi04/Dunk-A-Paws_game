import Foundation

enum ObjectiveType: String, Codable {
    case scoreBasket
    case collectStarsAndScore
    case bankShot
    case breakIceAndScore
    case useTrampoline
    case avoidFan
}

struct LevelObjective: Codable {
    let type: ObjectiveType
    let description: String
    var requiredStars: Int = 0

    static let scoreBasket = LevelObjective(
        type: .scoreBasket,
        description: "Score the basket!"
    )

    static func collectStars(_ count: Int) -> LevelObjective {
        LevelObjective(
            type: .collectStarsAndScore,
            description: "Collect \(count) star\(count > 1 ? "s" : "") and score!",
            requiredStars: count
        )
    }

    static let bankShot = LevelObjective(
        type: .bankShot,
        description: "Make a bank shot off the backboard!"
    )

    static let breakIceAndScore = LevelObjective(
        type: .breakIceAndScore,
        description: "Break the ice wall and score!"
    )

    static let useTrampoline = LevelObjective(
        type: .useTrampoline,
        description: "Bounce off the trampoline before scoring!"
    )

    static let avoidFan = LevelObjective(
        type: .avoidFan,
        description: "Avoid the fan wind and score!"
    )
}
