import Foundation
import SpriteKit

class FanNode: SKNode {
    private var housing: SKShapeNode!
    private var bladesContainer: SKNode!
    private var bladeNodes: [SKShapeNode] = []
    private var forceZone: SKNode!

    var rotationSpeed: CGFloat = 0
    var forceRadius: CGFloat = 120
    var forceStrength: CGFloat = GamePhysicsConfig.fanForce
    var windDirection: CGVector = CGVector(dx: 1, dy: 0)
    var angle: CGFloat = 0

    var oscillationEnabled: Bool = false
    var oscillationRange: CGFloat = 0
    private var oscillationAngle: CGFloat = 0
    private var oscillationSpeed: CGFloat = 1

    func setup(position: CGPoint, size: CGFloat = 50,
               rotationSpeed: CGFloat = 5,
               forceRadius: CGFloat = 140,
               angleDegrees: CGFloat = 0,
               oscillate: Bool = false,
               oscRange: CGFloat = 0) {
        self.position = position
        self.name = "fan"
        self.zPosition = 3
        self.rotationSpeed = rotationSpeed
        self.forceRadius = forceRadius
        self.angle = angleDegrees * .pi / 180
        self.oscillationEnabled = oscillate
        self.oscillationRange = oscRange * .pi / 180

        setupHousing(size: size)
        setupBlades(size: size * 0.85)
        setupForceZone()
    }

    private func setupHousing(size: CGFloat) {
        let ringPath = UIBezierPath(arcCenter: .zero,
                                     radius: size / 2 + 4,
                                     startAngle: 0,
                                     endAngle: .pi * 2,
                                     clockwise: true)
        housing = SKShapeNode(path: ringPath.cgPath)
        housing.strokeColor = UIColor(red: 0.4, green: 0.45, blue: 0.55, alpha: 1.0)
        housing.lineWidth = 6
        housing.zPosition = 1
        addChild(housing)

        let grillCount = 8
        for i in 0..<grillCount {
            let grillAngle = CGFloat(i) / CGFloat(grillCount) * .pi * 2
            let x1 = cos(grillAngle) * (size / 2 - 2)
            let y1 = sin(grillAngle) * (size / 2 - 2)
            let x2 = cos(grillAngle) * 4
            let y2 = sin(grillAngle) * 4
            let grillPath = CGMutablePath()
            grillPath.move(to: CGPoint(x: x1, y: y1))
            grillPath.addLine(to: CGPoint(x: x2, y: y2))
            let grill = SKShapeNode(path: grillPath)
            grill.strokeColor = UIColor(red: 0.6, green: 0.65, blue: 0.75, alpha: 0.5)
            grill.lineWidth = 2
            addChild(grill)
        }

        let hub = SKShapeNode(circleOfRadius: 8)
        hub.fillColor = UIColor(red: 0.35, green: 0.4, blue: 0.5, alpha: 1.0)
        hub.strokeColor = UIColor(red: 0.2, green: 0.25, blue: 0.3, alpha: 1.0)
        hub.lineWidth = 2
        hub.zPosition = 2
        addChild(hub)
    }

    private func setupBlades(size: CGFloat) {
        bladesContainer = SKNode()
        addChild(bladesContainer)

        let bladeCount = 4
        for i in 0..<bladeCount {
            let bladeAngle = CGFloat(i) / CGFloat(bladeCount) * .pi * 2
            let bladePath = CGMutablePath()
            bladePath.move(to: CGPoint(x: -2, y: 0))
            bladePath.addQuadCurve(to: CGPoint(x: 2, y: 0),
                                    control: CGPoint(x: 0, y: 4))
            bladePath.addLine(to: CGPoint(x: size / 2, y: -size / 8))
            bladePath.addQuadCurve(to: CGPoint(x: -size / 2, y: -size / 8),
                                    control: CGPoint(x: 0, y: size / 4))
            bladePath.closeSubpath()

            let blade = SKShapeNode(path: bladePath)
            blade.fillColor = UIColor(red: 0.7, green: 0.75, blue: 0.85, alpha: 0.9)
            blade.strokeColor = UIColor(red: 0.4, green: 0.45, blue: 0.55, alpha: 1.0)
            blade.lineWidth = 1
            blade.zRotation = bladeAngle
            blade.zPosition = 0
            bladesContainer.addChild(blade)
            bladeNodes.append(blade)
        }
    }

    private func setupForceZone() {
        forceZone = SKNode()
        forceZone.name = "fanZone"
        let zoneSize = CGSize(width: forceRadius + 40, height: forceRadius)
        let physics = SKPhysicsBody(rectangleOf: zoneSize,
                                     center: CGPoint(x: forceRadius / 2, y: 0))
        physics.isDynamic = false
        physics.categoryBitMask = PhysicsCategories.fan
        physics.contactTestBitMask = PhysicsCategories.animal
        physics.collisionBitMask = 0
        forceZone.physicsBody = physics
        addChild(forceZone)
    }

    func update(currentTime: TimeInterval, deltaTime: TimeInterval) {
        bladesContainer.zRotation += rotationSpeed * CGFloat(deltaTime)

        if oscillationEnabled {
            oscillationAngle += oscillationSpeed * CGFloat(deltaTime)
            let oscOffset = sin(oscillationAngle) * oscillationRange
            zRotation = angle + oscOffset
        } else {
            zRotation = angle
        }
    }

    func applyWindForce(to animal: AnimalNode) {
        guard let physics = animal.physicsBody else { return }
        guard let scene = scene else { return }

        animal.hitFan = true

        let fanInScene = self.convert(CGPoint.zero, to: scene)
        let animalInScene = animal.convert(CGPoint.zero, to: scene)
        let dxPos = animalInScene.x - fanInScene.x
        let dyPos = animalInScene.y - fanInScene.y
        let dist = hypot(dxPos, dyPos)

        if dist < forceRadius + 20 {
            let falloff = max(0, 1 - dist / (forceRadius + 20))
            let rot = zRotation
            let dx = cos(rot)
            let dy = sin(rot)
            let force = CGVector(dx: dx * forceStrength * falloff,
                                  dy: dy * forceStrength * falloff * 0.3)

            physics.applyForce(force)

            if arc4random_uniform(20) == 0 {
                showWindParticle(dx: dx, dy: dy)
            }
        }
    }

    private func showWindParticle(dx: CGFloat, dy: CGFloat) {
        let particle = SKShapeNode(circleOfRadius: 3)
        particle.fillColor = UIColor.white.withAlphaComponent(0.5)
        particle.strokeColor = .clear
        particle.position = CGPoint(x: dx * 20, y: dy * 20)
        particle.zPosition = 1
        addChild(particle)

        let move = SKAction.moveBy(x: dx * forceRadius * 0.8,
                                    y: dy * forceRadius * 0.3,
                                    duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        particle.run(SKAction.sequence([SKAction.group([move, fade]), SKAction.removeFromParent()]))
    }
}
