import Foundation
import CoreGraphics

class LevelManager {
    static let shared = LevelManager()

    private init() {}

    func allLevels() -> [LevelData] {
        return (1...20).map { levelID($0) }
    }

    func levelID(_ id: Int) -> LevelData {
        switch id {
        case 1: return level1()
        case 2: return level2()
        case 3: return level3()
        case 4: return level4()
        case 5: return level5()
        case 6: return level6()
        case 7: return level7()
        case 8: return level8()
        case 9: return level9()
        case 10: return level10()
        case 11: return level11()
        case 12: return level12()
        case 13: return level13()
        case 14: return level14()
        case 15: return level15()
        case 16: return level16()
        case 17: return level17()
        case 18: return level18()
        case 19: return level19()
        case 20: return level20()
        default: return level1()
        }
    }

    private let W: CGFloat = 390
    private let H: CGFloat = 844

    private func level1() -> LevelData {
        LevelData(
            id: 1, name: "First Basket",
            objective: .scoreBasket,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 290, y: 320),
            stars: [CGPoint(x: 185, y: 240)],
            parShots: 3,
            theme: .sunnyPark
        )
    }

    private func level2() -> LevelData {
        LevelData(
            id: 2, name: "Higher Hoop",
            objective: .scoreBasket,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 300, y: 420),
            stars: [CGPoint(x: 200, y: 280), CGPoint(x: 250, y: 360)],
            parShots: 3,
            theme: .sunnyPark
        )
    }

    private func level3() -> LevelData {
        LevelData(
            id: 3, name: "Bank Shot",
            objective: .bankShot,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 330, y: 300),
            stars: [CGPoint(x: 200, y: 220)],
            parShots: 3,
            theme: .sunnyPark
        )
    }

    private func level4() -> LevelData {
        LevelData(
            id: 4, name: "Trampoline Time",
            objective: .useTrampoline,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 310, y: 520),
            obstacles: [
                ObstacleData(type: .trampoline,
                             position: CGPoint(x: 200, y: 170),
                             size: CGSize(width: 80, height: 25))
            ],
            stars: [CGPoint(x: 220, y: 280), CGPoint(x: 280, y: 400)],
            parShots: 4,
            theme: .candyWorld
        )
    }

    private func level5() -> LevelData {
        LevelData(
            id: 5, name: "Moving Target",
            objective: .scoreBasket,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 290, y: 350),
            hoopMovement: HoopMovementData(type: .horizontal, range: 50, speed: 1.5),
            stars: [CGPoint(x: 190, y: 250)],
            parShots: 4,
            theme: .candyWorld
        )
    }

    private func level6() -> LevelData {
        LevelData(
            id: 6, name: "Fan Blower",
            objective: .avoidFan,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 310, y: 380),
            obstacles: [
                ObstacleData(type: .fan,
                             position: CGPoint(x: 195, y: 280),
                             size: CGSize(width: 50, height: 50),
                             extra: ["angle": 0, "force": 300])
            ],
            stars: [CGPoint(x: 220, y: 300), CGPoint(x: 280, y: 330)],
            parShots: 4,
            theme: .factory
        )
    }

    private func level7() -> LevelData {
        LevelData(
            id: 7, name: "Double Trampoline",
            objective: .collectStars(2),
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 330, y: 600),
            obstacles: [
                ObstacleData(type: .trampoline,
                             position: CGPoint(x: 160, y: 160),
                             size: CGSize(width: 70, height: 22)),
                ObstacleData(type: .trampoline,
                             position: CGPoint(x: 260, y: 330),
                             size: CGSize(width: 70, height: 22))
            ],
            stars: [CGPoint(x: 190, y: 250), CGPoint(x: 290, y: 420), CGPoint(x: 320, y: 520)],
            parShots: 4,
            theme: .candyWorld
        )
    }

    private func level8() -> LevelData {
        LevelData(
            id: 8, name: "Vertical Move",
            objective: .scoreBasket,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 300, y: 400),
            hoopMovement: HoopMovementData(type: .vertical, range: 60, speed: 1.2),
            stars: [CGPoint(x: 180, y: 260), CGPoint(x: 260, y: 350)],
            parShots: 4,
            theme: .arctic
        )
    }

    private func level9() -> LevelData {
        LevelData(
            id: 9, name: "Ice Wall",
            animal: .panda,
            objective: .breakIceAndScore,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 310, y: 280),
            obstacles: [
                ObstacleData(type: .iceBlock,
                             position: CGPoint(x: 200, y: 220),
                             size: CGSize(width: 55, height: 70))
            ],
            stars: [CGPoint(x: 170, y: 180)],
            parShots: 4,
            theme: .arctic,
            requiredAnimal: .panda
        )
    }

    private func level10() -> LevelData {
        LevelData(
            id: 10, name: "Cat's Air Jump",
            animal: .cat,
            objective: .collectStars(1),
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 320, y: 450),
            obstacles: [
                ObstacleData(type: .wall,
                             position: CGPoint(x: 220, y: 300),
                             size: CGSize(width: 10, height: 180))
            ],
            stars: [CGPoint(x: 200, y: 260), CGPoint(x: 280, y: 380)],
            parShots: 4,
            theme: .sunnyPark,
            requiredAnimal: .cat
        )
    }

    private func level11() -> LevelData {
        LevelData(
            id: 11, name: "Swinging Hoop",
            objective: .scoreBasket,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 300, y: 380),
            hoopMovement: HoopMovementData(type: .swinging,
                                            range: 20, speed: 1.3,
                                            anchorX: 300, anchorY: 500),
            stars: [CGPoint(x: 190, y: 250)],
            parShots: 5,
            theme: .factory
        )
    }

    private func level12() -> LevelData {
        LevelData(
            id: 12, name: "Penguin Slide",
            animal: .penguin,
            objective: .scoreBasket,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 330, y: 240),
            obstacles: [
                ObstacleData(type: .iceBlock,
                             position: CGPoint(x: 180, y: 130),
                             size: CGSize(width: 80, height: 10))
            ],
            stars: [CGPoint(x: 230, y: 170), CGPoint(x: 290, y: 220)],
            parShots: 4,
            theme: .arctic,
            requiredAnimal: .penguin
        )
    }

    private func level13() -> LevelData {
        LevelData(
            id: 13, name: "Otter Splash",
            animal: .otter,
            objective: .collectStars(2),
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 320, y: 520),
            obstacles: [
                ObstacleData(type: .waterZone,
                             position: CGPoint(x: 180, y: 180),
                             size: CGSize(width: 90, height: 30)),
                ObstacleData(type: .wall,
                             position: CGPoint(x: 250, y: 380),
                             size: CGSize(width: 10, height: 140))
            ],
            stars: [CGPoint(x: 190, y: 260), CGPoint(x: 280, y: 440)],
            parShots: 5,
            theme: .sunnyPark,
            requiredAnimal: .otter
        )
    }

    private func level14() -> LevelData {
        LevelData(
            id: 14, name: "Panda's Rampage",
            animal: .panda,
            objective: .breakIceAndScore,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 310, y: 280),
            obstacles: [
                ObstacleData(type: .iceBlock,
                             position: CGPoint(x: 180, y: 200),
                             size: CGSize(width: 50, height: 60)),
                ObstacleData(type: .iceBlock,
                             position: CGPoint(x: 230, y: 280),
                             size: CGSize(width: 50, height: 60))
            ],
            stars: [CGPoint(x: 200, y: 300)],
            parShots: 5,
            theme: .arctic,
            requiredAnimal: .panda
        )
    }

    private func level15() -> LevelData {
        LevelData(
            id: 15, name: "Double Fan",
            objective: .avoidFan,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 320, y: 480),
            obstacles: [
                ObstacleData(type: .fan,
                             position: CGPoint(x: 160, y: 240),
                             size: CGSize(width: 45, height: 45),
                             extra: ["angle": 20, "force": 250]),
                ObstacleData(type: .fan,
                             position: CGPoint(x: 260, y: 380),
                             size: CGSize(width: 45, height: 45),
                             extra: ["angle": -30, "force": 250])
            ],
            stars: [CGPoint(x: 210, y: 300), CGPoint(x: 280, y: 420)],
            parShots: 5,
            theme: .factory
        )
    }

    private func level16() -> LevelData {
        LevelData(
            id: 16, name: "Trampoline + Fan",
            objective: .collectStars(2),
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 320, y: 580),
            obstacles: [
                ObstacleData(type: .trampoline,
                             position: CGPoint(x: 180, y: 160),
                             size: CGSize(width: 75, height: 22)),
                ObstacleData(type: .fan,
                             position: CGPoint(x: 260, y: 420),
                             size: CGSize(width: 45, height: 45),
                             extra: ["angle": 60, "force": 280])
            ],
            stars: [CGPoint(x: 210, y: 300), CGPoint(x: 280, y: 460), CGPoint(x: 310, y: 520)],
            parShots: 5,
            theme: .candyWorld
        )
    }

    private func level17() -> LevelData {
        LevelData(
            id: 17, name: "Disappearing Hoop",
            objective: .scoreBasket,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 300, y: 420),
            hoopMovement: HoopMovementData(type: .disappearing, range: 0, speed: 0.8),
            obstacles: [
                ObstacleData(type: .trampoline,
                             position: CGPoint(x: 200, y: 170),
                             size: CGSize(width: 70, height: 20))
            ],
            stars: [CGPoint(x: 190, y: 260)],
            parShots: 5,
            theme: .factory
        )
    }

    private func level18() -> LevelData {
        LevelData(
            id: 18, name: "Rotating Hoop",
            objective: .bankShot,
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 310, y: 400),
            hoopMovement: HoopMovementData(type: .rotating, range: 15, speed: 1.0),
            obstacles: [
                ObstacleData(type: .iceBlock,
                             position: CGPoint(x: 190, y: 200),
                             size: CGSize(width: 45, height: 55)),
                ObstacleData(type: .fan,
                             position: CGPoint(x: 250, y: 290),
                             size: CGSize(width: 45, height: 45),
                             extra: ["angle": -10, "force": 200])
            ],
            stars: [CGPoint(x: 220, y: 300)],
            parShots: 6,
            theme: .candyWorld
        )
    }

    private func level19() -> LevelData {
        LevelData(
            id: 19, name: "Combo Madness",
            objective: .collectStars(3),
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 330, y: 650),
            obstacles: [
                ObstacleData(type: .trampoline,
                             position: CGPoint(x: 160, y: 150),
                             size: CGSize(width: 70, height: 22)),
                ObstacleData(type: .trampoline,
                             position: CGPoint(x: 250, y: 340),
                             size: CGSize(width: 70, height: 22)),
                ObstacleData(type: .trampoline,
                             position: CGPoint(x: 180, y: 500),
                             size: CGSize(width: 70, height: 22)),
                ObstacleData(type: .fan,
                             position: CGPoint(x: 280, y: 540),
                             size: CGSize(width: 45, height: 45),
                             extra: ["angle": 45, "force": 220])
            ],
            stars: [CGPoint(x: 200, y: 230), CGPoint(x: 270, y: 400), CGPoint(x: 230, y: 560)],
            parShots: 6,
            theme: .candyWorld
        )
    }

    private func level20() -> LevelData {
        LevelData(
            id: 20, name: "Grand Finale",
            objective: .collectStars(2),
            launchPosition: CGPoint(x: 115, y: 175),
            hoopPosition: CGPoint(x: 310, y: 680),
            hoopMovement: HoopMovementData(type: .horizontal, range: 40, speed: 1.2),
            obstacles: [
                ObstacleData(type: .trampoline,
                             position: CGPoint(x: 170, y: 155),
                             size: CGSize(width: 70, height: 22)),
                ObstacleData(type: .iceBlock,
                             position: CGPoint(x: 240, y: 280),
                             size: CGSize(width: 50, height: 70)),
                ObstacleData(type: .fan,
                             position: CGPoint(x: 160, y: 380),
                             size: CGSize(width: 45, height: 45),
                             extra: ["angle": 30, "force": 280]),
                ObstacleData(type: .trampoline,
                             position: CGPoint(x: 260, y: 500),
                             size: CGSize(width: 70, height: 22)),
                ObstacleData(type: .fan,
                             position: CGPoint(x: 290, y: 590),
                             size: CGSize(width: 45, height: 45),
                             extra: ["angle": -20, "force": 200])
            ],
            stars: [CGPoint(x: 200, y: 230), CGPoint(x: 270, y: 380), CGPoint(x: 290, y: 580)],
            parShots: 6,
            theme: .factory
        )
    }
}
