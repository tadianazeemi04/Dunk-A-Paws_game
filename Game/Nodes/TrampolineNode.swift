import Foundation
import SpriteKit

class TrampolineNode: SKNode {
    private var platform: SKShapeNode!
    private var base: SKShapeNode!
    private var springs: [SKShapeNode] = []
    private var bounceForce: CGFloat = GamePhysicsConfig.trampolineForce

    var onBounce: (() -> Void)?
    var hasBounced: Bool = false

    func setup(position: CGPoint, size: CGSize = CGSize(width: 90, height: 25)) {
        self.position = position
        self.name = "trampoline"
        self.zPosition = 3

        let baseRect = CGRect(x: -size.width / 2, y: -size.height / 2,
                               width: size.width, height: size.height * 0.4)
        base = SKShapeNode(rect: baseRect, cornerRadius: 4)
        base.fillColor = UIColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 1.0)
        base.strokeColor = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        base.lineWidth = 2
        addChild(base)

        for i in 0..<4 {
            let spring = SKShapeNode()
            let springPath = CGMutablePath()
            let sx = -size.width / 2 + 12 + CGFloat(i) * ((size.width - 24) / 3)
            springPath.move(to: CGPoint(x: sx, y: -size.height / 2 + 5))
            for j in 0..<3 {
                springPath.addLine(to: CGPoint(x: sx + (j % 2 == 0 ? -3 : 3),
                                                y: -size.height / 2 + 5 + CGFloat(j + 1) * 3))
            }
            springPath.addLine(to: CGPoint(x: sx, y: -size.height / 2 + 5 + 11))
            spring.path = springPath
            spring.strokeColor = UIColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0)
            spring.lineWidth = 2
            springs.append(spring)
            addChild(spring)
        }

        let platformRect = CGRect(x: -size.width / 2 - 4, y: 0,
                                    width: size.width + 8, height: 10)
        platform = SKShapeNode(rect: platformRect, cornerRadius: 5)
        platform.fillColor = UIColor(red: 1.0, green: 0.35, blue: 0.45, alpha: 1.0)
        platform.strokeColor = UIColor(red: 0.8, green: 0.2, blue: 0.3, alpha: 1.0)
        platform.lineWidth = 2
        addChild(platform)

        let padding: CGFloat = 8
        let physicsRect = CGRect(x: -size.width / 2 + padding, y: 0,
                                  width: size.width - padding * 2, height: 12)
        let physics = SKPhysicsBody(rectangleOf: physicsRect.size,
                                     center: CGPoint(x: 0, y: physicsRect.midY))
        physics.isDynamic = false
        physics.restitution = 1.2
        physics.friction = 0.2
        physics.categoryBitMask = PhysicsCategories.trampoline
        physics.contactTestBitMask = PhysicsCategories.animal
        physics.collisionBitMask = PhysicsCategories.animal
        self.physicsBody = physics
    }

    func bounce(animal: AnimalNode) {
        guard let physics = animal.physicsBody else { return }
        hasBounced = true
        animal.hitTrampoline = true

        var velocity = physics.velocity
        velocity.dy = max(abs(velocity.dy), bounceForce)
        velocity.dx *= 0.95
        physics.velocity = velocity

        let impulse = CGVector(dx: 0, dy: bounceForce * 0.3)
        physics.applyImpulse(impulse)

        animateBounce()

        HapticManager.shared.trampolineBounce()
        SoundManager.shared.playSound("trampoline")
        showBounceParticles()

        onBounce?()
    }

    private func animateBounce() {
        let compress = SKAction.scaleY(to: 0.6, duration: 0.06)
        let stretch = SKAction.scaleY(to: 1.15, duration: 0.08)
        let back = SKAction.scaleY(to: 1.0, duration: 0.1)
        platform.run(SKAction.sequence([compress, stretch, back]))

        for spring in springs {
            let sCompress = SKAction.scaleY(to: 0.5, duration: 0.06)
            let sStretch = SKAction.scaleY(to: 1.3, duration: 0.08)
            let sBack = SKAction.scaleY(to: 1.0, duration: 0.1)
            spring.run(SKAction.sequence([sCompress, sStretch, sBack]))
        }
    }

    private func showBounceParticles() {
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 3 + CGFloat(arc4random_uniform(3)))
            particle.fillColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
            particle.strokeColor = .clear
            let spread = (platform.frame.size.width)
            particle.position = CGPoint(
                x: -spread / 2 + CGFloat(arc4random_uniform(UInt32(spread))),
                y: platform.frame.maxY
            )
            particle.zPosition = 10
            addChild(particle)

            let dx = CGFloat(arc4random_uniform(80)) - 40
            let dy = 30 + CGFloat(arc4random_uniform(40))
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.4)
            let fade = SKAction.fadeOut(withDuration: 0.4)
            let scale = SKAction.scale(to: 0.3, duration: 0.4)
            particle.run(SKAction.sequence([SKAction.group([move, fade, scale]), SKAction.removeFromParent()]))
        }
    }

    func reset() {
        hasBounced = false
        platform.setScale(1.0)
        springs.forEach { $0.setScale(1.0) }
    }
}
