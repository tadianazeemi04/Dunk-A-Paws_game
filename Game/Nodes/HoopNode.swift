import Foundation
import SpriteKit

class HoopNode: SKNode {
    private var backboard: SKShapeNode!
    private var rim: SKShapeNode!
    private var netContainer: SKNode!
    private var rimLeft: SKShapeNode!
    private var rimRight: SKShapeNode!
    private var scoringSensor: SKNode!
    private var hoopContainer: SKNode!

    var movementType: HoopMovementType = .static
    var movementRange: CGFloat = 0
    var movementSpeed: CGFloat = 0
    var originalPosition: CGPoint = .zero
    var swingAnchor: CGPoint = .zero
    var swingAngle: CGFloat = 0

    var onScore: ((ScoreInfo) -> Void)?
    private var passedAboveRim: Bool = false
    private var animalEnteredFromTop: Bool = false
    private var swishCheck: Bool = true

    struct ScoreInfo {
        var isSwish: Bool
        var isBankShot: Bool
        var isRimShot: Bool
    }

    func setup(hoopPosition: CGPoint, movement: HoopMovementData) {
        self.position = hoopPosition
        self.originalPosition = hoopPosition
        self.movementType = movement.type
        self.movementRange = movement.range
        self.movementSpeed = movement.speed
        self.swingAnchor = CGPoint(x: movement.anchorX, y: movement.anchorY)

        hoopContainer = SKNode()
        addChild(hoopContainer)

        setupBackboard()
        setupRim()
        setupNet()
        setupScoringSensor()
    }

    private func setupBackboard() {
        let bbThickness: CGFloat = 12
        let bbHeight: CGFloat = 84
        let bbX: CGFloat = 38
        let bbY: CGFloat = 38

        // Backboard (seen from side: vertical board behind rim on the right)
        let bb = SKShapeNode(rectOf: CGSize(width: bbThickness, height: bbHeight),
                              cornerRadius: 3)
        bb.fillColor = UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 0.95)
        bb.strokeColor = UIColor(red: 0.25, green: 0.3, blue: 0.38, alpha: 1.0)
        bb.lineWidth = 2.5
        bb.position = CGPoint(x: bbX, y: bbY)
        bb.zPosition = 2
        hoopContainer.addChild(bb)
        backboard = bb

        // Red target line on the front (left) face of the backboard facing the shooter
        let targetLine = SKShapeNode(rectOf: CGSize(width: 3, height: 36), cornerRadius: 1)
        targetLine.fillColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        targetLine.strokeColor = .clear
        targetLine.position = CGPoint(x: bbX - 4.5, y: bbY - 8)
        targetLine.zPosition = 2.5
        hoopContainer.addChild(targetLine)

        // Physics body on the backboard for bank shots
        let bbPhysics = SKPhysicsBody(rectangleOf: CGSize(width: bbThickness, height: bbHeight))
        bbPhysics.isDynamic = false
        bbPhysics.friction = 0.4
        bbPhysics.restitution = 0.55
        bbPhysics.categoryBitMask = PhysicsCategories.backboard
        bbPhysics.contactTestBitMask = PhysicsCategories.animal
        bbPhysics.collisionBitMask = PhysicsCategories.animal
        bb.physicsBody = bbPhysics
        bb.name = "backboard"

        // Support pole / mounting bracket extending to the right behind the backboard
        let pole = SKShapeNode(rectOf: CGSize(width: 24, height: 10), cornerRadius: 2)
        pole.fillColor = UIColor(red: 0.35, green: 0.38, blue: 0.42, alpha: 1.0)
        pole.strokeColor = UIColor(red: 0.2, green: 0.22, blue: 0.25, alpha: 1.0)
        pole.lineWidth = 1.5
        pole.position = CGPoint(x: bbX + 16, y: bbY - 20)
        pole.zPosition = 1
        hoopContainer.addChild(pole)
    }

    private func setupRim() {
        let rimRadius: CGFloat = 32
        let rimCenterY: CGFloat = 5

        // Realistic perspective basketball rim (ellipse seen from 3/4 side angle)
        let rimRect = CGRect(x: -rimRadius, y: rimCenterY - 5, width: rimRadius * 2, height: 10)
        let rimEllipse = UIBezierPath(ovalIn: rimRect)
        let rimShape = SKShapeNode(path: rimEllipse.cgPath)
        rimShape.strokeColor = UIColor(red: 1.0, green: 0.45, blue: 0.1, alpha: 1.0)
        rimShape.lineWidth = 4.5
        rimShape.fillColor = .clear
        rimShape.zPosition = 4
        hoopContainer.addChild(rimShape)
        self.rim = rimShape

        // Front rim lip (left edge facing the shooter)
        rimLeft = SKShapeNode(circleOfRadius: 4.5)
        rimLeft.fillColor = UIColor(red: 1.0, green: 0.4, blue: 0.08, alpha: 1.0)
        rimLeft.strokeColor = UIColor(red: 0.7, green: 0.25, blue: 0.05, alpha: 1.0)
        rimLeft.lineWidth = 1
        rimLeft.position = CGPoint(x: -rimRadius + 2, y: rimCenterY)
        rimLeft.zPosition = 5
        hoopContainer.addChild(rimLeft)

        // Back rim lip (right edge attached to backboard)
        rimRight = SKShapeNode(circleOfRadius: 4.5)
        rimRight.fillColor = UIColor(red: 1.0, green: 0.4, blue: 0.08, alpha: 1.0)
        rimRight.strokeColor = UIColor(red: 0.7, green: 0.25, blue: 0.05, alpha: 1.0)
        rimRight.lineWidth = 1
        rimRight.position = CGPoint(x: rimRadius - 2, y: rimCenterY)
        rimRight.zPosition = 5
        hoopContainer.addChild(rimRight)

        let leftBody = SKPhysicsBody(circleOfRadius: 6)
        leftBody.isDynamic = false
        leftBody.restitution = 0.8
        leftBody.friction = 0.2
        leftBody.categoryBitMask = PhysicsCategories.rim
        leftBody.contactTestBitMask = PhysicsCategories.animal
        leftBody.collisionBitMask = PhysicsCategories.animal
        rimLeft.physicsBody = leftBody
        rimLeft.name = "rim"

        let rightBody = SKPhysicsBody(circleOfRadius: 6)
        rightBody.isDynamic = false
        rightBody.restitution = 0.8
        rightBody.friction = 0.2
        rightBody.categoryBitMask = PhysicsCategories.rim
        rightBody.contactTestBitMask = PhysicsCategories.animal
        rightBody.collisionBitMask = PhysicsCategories.animal
        rimRight.physicsBody = rightBody
        rimRight.name = "rim"

        // Small mounting bracket connecting the back of the rim to the backboard
        let bracket = SKShapeNode(rectOf: CGSize(width: 10, height: 8), cornerRadius: 1)
        bracket.fillColor = UIColor(red: 0.95, green: 0.45, blue: 0.1, alpha: 1.0)
        bracket.strokeColor = .clear
        bracket.position = CGPoint(x: rimRadius + 3, y: rimCenterY)
        bracket.zPosition = 3
        hoopContainer.addChild(bracket)
    }

    private func setupNet() {
        netContainer = SKNode()
        netContainer.zPosition = 3.5
        hoopContainer.addChild(netContainer)

        let rimRadius: CGFloat = 32
        let rimCenterY: CGFloat = 5
        let netLength: CGFloat = 36
        let strands = 8

        for i in 0...strands {
            let t = CGFloat(i) / CGFloat(strands)
            let startX = -rimRadius + t * rimRadius * 2
            let endX = -rimRadius * 0.5 + t * rimRadius
            let startY = rimCenterY - 2
            let endY = rimCenterY - netLength

            let strandPath = CGMutablePath()
            strandPath.move(to: CGPoint(x: startX, y: startY))
            strandPath.addQuadCurve(to: CGPoint(x: endX, y: endY),
                                     control: CGPoint(x: (startX + endX) / 2, y: (startY + endY) / 2 - 5))
            let strand = SKShapeNode(path: strandPath)
            strand.strokeColor = UIColor(white: 0.95, alpha: 0.9)
            strand.lineWidth = 1.5
            netContainer.addChild(strand)
        }

        for row in 1..<3 {
            let y = rimCenterY - CGFloat(row) * (netLength / 3)
            let widthFactor = 1.0 - CGFloat(row) * 0.15
            let crossPath = CGMutablePath()
            for i in 0...4 {
                let t = CGFloat(i) / 4.0
                let x = -rimRadius * widthFactor + t * rimRadius * 2 * widthFactor
                if i == 0 {
                    crossPath.move(to: CGPoint(x: x, y: y))
                } else {
                    crossPath.addLine(to: CGPoint(x: x, y: y))
                }
            }
            let cross = SKShapeNode(path: crossPath)
            cross.strokeColor = UIColor(white: 0.9, alpha: 0.6)
            cross.lineWidth = 1
            netContainer.addChild(cross)
        }
    }

    private func setupScoringSensor() {
        scoringSensor = SKNode()
        let sensorSize = CGSize(width: 40, height: 10)
        let sensor = SKPhysicsBody(rectangleOf: sensorSize)
        sensor.isDynamic = false
        sensor.categoryBitMask = PhysicsCategories.scoringSensor
        sensor.contactTestBitMask = PhysicsCategories.animal
        sensor.collisionBitMask = 0
        scoringSensor.physicsBody = sensor
        scoringSensor.position = CGPoint(x: 0, y: -10)
        scoringSensor.name = "scoringSensor"
        hoopContainer.addChild(scoringSensor)
    }

    func updateMovement(currentTime: TimeInterval) {
        let time = CGFloat(currentTime)

        switch movementType {
        case .static:
            break
        case .horizontal:
            let offset = sin(time * movementSpeed) * movementRange
            position.x = originalPosition.x + offset
        case .vertical:
            let offset = sin(time * movementSpeed) * movementRange
            position.y = originalPosition.y + offset
        case .rotating:
            hoopContainer.zRotation = sin(time * movementSpeed) * movementRange * 0.01
        case .swinging:
            swingAngle = sin(time * movementSpeed) * (movementRange * .pi / 180)
            let dx = sin(swingAngle) * abs(originalPosition.y - swingAnchor.y)
            let dy = -abs(originalPosition.y - swingAnchor.y) * (1 - cos(swingAngle))
            position.x = originalPosition.x + dx
            position.y = originalPosition.y + dy
            hoopContainer.zRotation = swingAngle
        case .disappearing:
            let cycle = sin(time * movementSpeed)
            let alphaVal = (cycle + 1) * 0.5
            let alpha: CGFloat = alphaVal > 0.3 ? 1.0 : 0.15
            hoopContainer.alpha = alpha
            scoringSensor.isHidden = alpha < 0.5
            backboard.physicsBody?.categoryBitMask = alpha < 0.5 ? 0 : PhysicsCategories.backboard
            rimLeft.physicsBody?.categoryBitMask = alpha < 0.5 ? 0 : PhysicsCategories.rim
            rimRight.physicsBody?.categoryBitMask = alpha < 0.5 ? 0 : PhysicsCategories.rim
        }
    }

    func animalPassedAboveRim(_ animal: AnimalNode) {
        if animal.position.y > position.y + 10 {
            passedAboveRim = true
            animalEnteredFromTop = true
            swishCheck = true
        }
    }

    func checkScore(animal: AnimalNode) -> Bool {
        let worldSensorPos = convert(scoringSensor.position, to: parent ?? self)
        let dist = hypot(animal.position.x - position.x,
                          animal.position.y - worldSensorPos.y)

        if dist < 25 && passedAboveRim && animalEnteredFromTop {
            let info = ScoreInfo(
                isSwish: swishCheck && !animal.hitRim && !animal.hitBackboard,
                isBankShot: animal.hitBackboard && !animal.hitRim,
                isRimShot: animal.hitRim
            )
            onScore?(info)
            animateNetOnScore()
            resetScoringState()
            return true
        }
        return false
    }

    func rimHit() {
        swishCheck = false
        let rattle = SKAction.sequence([
            SKAction.rotate(byAngle: 0.04, duration: 0.03),
            SKAction.rotate(byAngle: -0.06, duration: 0.04),
            SKAction.rotate(byAngle: 0.04, duration: 0.03),
            SKAction.rotate(toAngle: 0, duration: 0.04)
        ])
        rim?.run(rattle)
    }

    private func animateNetOnScore() {
        let scaleY = SKAction.scaleY(to: 1.3, duration: 0.1)
        let scaleBack = SKAction.scaleY(to: 1.0, duration: 0.2)
        netContainer.run(SKAction.sequence([scaleY, scaleBack]))

        let container = netContainer
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -2, y: 0, duration: 0.05),
            SKAction.moveBy(x: 4, y: 0, duration: 0.05),
            SKAction.moveBy(x: -2, y: 0, duration: 0.05)
        ])
        container?.run(shake)
    }

    private func resetScoringState() {
        passedAboveRim = false
        animalEnteredFromTop = false
        swishCheck = true
    }

    func reset() {
        resetScoringState()
        position = originalPosition
        hoopContainer.zRotation = 0
        hoopContainer.alpha = 1
        scoringSensor.isHidden = false
    }
}
