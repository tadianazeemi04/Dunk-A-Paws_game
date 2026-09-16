import Foundation

enum GameState: String {
    case menu
    case characterSelection
    case levelSelection
    case ready
    case aiming
    case flying
    case scored
    case failed
    case levelComplete
    case paused
    case settings
}

enum HoopMovementType: String, Codable {
    case `static`
    case horizontal
    case vertical
    case rotating
    case swinging
    case disappearing
}

enum ScoreType {
    case base
    case swish
    case bankShot
    case rimShot
    case star
    case trampoline
    case longShot
    case fewShot
    case combo
}
