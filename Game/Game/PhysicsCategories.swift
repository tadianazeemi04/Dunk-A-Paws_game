import Foundation

enum PhysicsCategories {
    static let animal: UInt32 = 1 << 0
    static let ground: UInt32 = 1 << 1
    static let hoop: UInt32 = 1 << 2
    static let rim: UInt32 = 1 << 3
    static let backboard: UInt32 = 1 << 4
    static let trampoline: UInt32 = 1 << 5
    static let fan: UInt32 = 1 << 6
    static let ice: UInt32 = 1 << 7
    static let star: UInt32 = 1 << 8
    static let boundary: UInt32 = 1 << 9
    static let water: UInt32 = 1 << 10
    static let scoringSensor: UInt32 = 1 << 11
    static let net: UInt32 = 1 << 12
}

struct GamePhysicsConfig {
    static let gravity: CGFloat = -4.5
    static let gravityMultiplier: CGFloat = 1.0
    static let launchPower: CGFloat = 10.5
    static let maxPullDistance: CGFloat = 95
    static let airResistance: CGFloat = 0.999
    static let fanForce: CGFloat = 350
    static let trampolineForce: CGFloat = 750
    static let groundSlamVelocity: CGFloat = -400
    static let catJumpImpulse: CGFloat = 320
    static let iceSlideMultiplier: CGFloat = 1.5
}
