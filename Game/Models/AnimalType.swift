import Foundation
import SwiftUI

enum AnimalType: String, CaseIterable, Codable, Identifiable {
    case panda
    case cat
    case penguin
    case otter

    var id: String { rawValue }

    var name: String {
        switch self {
        case .panda: return "Panda"
        case .cat: return "Cat"
        case .penguin: return "Penguin"
        case .otter: return "Otter"
        }
    }

    var emoji: String {
        switch self {
        case .panda: return "🐼"
        case .cat: return "🐱"
        case .penguin: return "🐧"
        case .otter: return "🦦"
        }
    }

    var abilityName: String {
        switch self {
        case .panda: return "GROUND SLAM"
        case .cat: return "AIR CORRECTION"
        case .penguin: return "ICE SLIDE"
        case .otter: return "WATER BOUNCE"
        }
    }

    var shortAbilityName: String {
        switch self {
        case .panda: return "SLAM"
        case .cat: return "AIR JUMP"
        case .penguin: return "SLIDE"
        case .otter: return "BOUNCE"
        }
    }

    var description: String {
        switch self {
        case .panda: return "Heavy hitter. Breaks ice with ground slam."
        case .cat: return "Agile. One mid-air correction per shot."
        case .penguin: return "Ice specialist. Glides smoothly on ice."
        case .otter: return "Water lover. Bounces off water zones."
        }
    }

    var tagline: String {
        switch self {
        case .panda: return "Heavy Hitter"
        case .cat: return "Agile & Quick"
        case .penguin: return "Ice Specialist"
        case .otter: return "Water Lover"
        }
    }

    var mass: CGFloat {
        switch self {
        case .panda: return 2.0
        case .cat: return 1.0
        case .penguin: return 1.1
        case .otter: return 1.2
        }
    }

    var bounce: CGFloat {
        switch self {
        case .panda: return 0.35
        case .cat: return 0.55
        case .penguin: return 0.45
        case .otter: return 0.5
        }
    }

    var friction: CGFloat {
        switch self {
        case .panda: return 0.8
        case .cat: return 0.4
        case .penguin: return 0.08
        case .otter: return 0.3
        }
    }

    var bodyColor: Color {
        switch self {
        case .panda: return .white
        case .cat: return Color(red: 1.0, green: 0.6, blue: 0.3)
        case .penguin: return Color(red: 0.1, green: 0.2, blue: 0.4)
        case .otter: return Color(red: 0.7, green: 0.45, blue: 0.25)
        }
    }

    var accentColor: Color {
        switch self {
        case .panda: return .black
        case .cat: return Color(red: 0.4, green: 0.2, blue: 0.1)
        case .penguin: return .white
        case .otter: return Color(red: 0.9, green: 0.7, blue: 0.4)
        }
    }
}
