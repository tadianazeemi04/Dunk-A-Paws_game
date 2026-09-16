import Foundation
import CoreGraphics

struct LevelData: Codable, Identifiable {
    let id: Int
    var name: String
    var animal: AnimalType?
    var objective: LevelObjective
    var launchPosition: CGPoint
    var hoopPosition: CGPoint
    var hoopMovement: HoopMovementData
    var obstacles: [ObstacleData]
    var stars: [CGPoint]
    var parShots: Int
    var theme: ThemeType
    var requiredAnimal: AnimalType?

    init(id: Int,
         name: String = "",
         animal: AnimalType? = nil,
         objective: LevelObjective = .scoreBasket,
         launchPosition: CGPoint,
         hoopPosition: CGPoint,
         hoopMovement: HoopMovementData = HoopMovementData(type: .static),
         obstacles: [ObstacleData] = [],
         stars: [CGPoint] = [],
         parShots: Int = 3,
         theme: ThemeType = .sunnyPark,
         requiredAnimal: AnimalType? = nil) {
        self.id = id
        self.name = name.isEmpty ? "Level \(id)" : name
        self.animal = animal
        self.objective = objective
        self.launchPosition = launchPosition
        self.hoopPosition = hoopPosition
        self.hoopMovement = hoopMovement
        self.obstacles = obstacles
        self.stars = stars
        self.parShots = parShots
        self.theme = theme
        self.requiredAnimal = requiredAnimal
    }
}

struct HoopMovementData: Codable {
    var type: HoopMovementType
    var range: CGFloat = 0
    var speed: CGFloat = 0
    var anchorX: CGFloat = 0
    var anchorY: CGFloat = 0
}

enum ThemeType: String, Codable, CaseIterable {
    case sunnyPark
    case candyWorld
    case arctic
    case factory

    var name: String {
        switch self {
        case .sunnyPark: return "Sunny Park"
        case .candyWorld: return "Candy World"
        case .arctic: return "Arctic"
        case .factory: return "Factory"
        }
    }

    var skyColor: (top: String, bottom: String) {
        switch self {
        case .sunnyPark: return ("#87CEEB", "#E0F6FF")
        case .candyWorld: return ("#FFB6C1", "#E6E6FA")
        case .arctic: return ("#B0E0E6", "#F0F8FF")
        case .factory: return ("#708090", "#D3D3D3")
        }
    }

    var groundColor: String {
        switch self {
        case .sunnyPark: return "#7CB342"
        case .candyWorld: return "#FF69B4"
        case .arctic: return "#E0FFFF"
        case .factory: return "#696969"
        }
    }
}
