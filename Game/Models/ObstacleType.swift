import Foundation
import CoreGraphics

enum ObstacleType: String, Codable {
    case trampoline
    case fan
    case iceBlock
    case movingPlatform
    case wall
    case waterZone
}

struct ObstacleData: Codable, Identifiable, Equatable {
    let id: UUID
    let type: ObstacleType
    let position: CGPoint
    let size: CGSize
    var rotation: CGFloat = 0
    var extra: [String: Double] = [:]

    init(id: UUID = UUID(), type: ObstacleType, position: CGPoint, size: CGSize, rotation: CGFloat = 0, extra: [String: Double] = [:]) {
        self.id = id
        self.type = type
        self.position = position
        self.size = size
        self.rotation = rotation
        self.extra = extra
    }

    static func == (lhs: ObstacleData, rhs: ObstacleData) -> Bool {
        lhs.id == rhs.id
    }
}
