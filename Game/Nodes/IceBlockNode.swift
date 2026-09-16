import Foundation
import SpriteKit

class IceBlockNode: SKNode {
    private var iceShape: SKShapeNode!
    private var cracksLayer: SKNode!
    private var health: Int = 3
    private var maxHealth: Int = 3
    private var broken: Bool = false

    var onBreak: (() -> Void)?
    var onCrack: (() -> Void)?

    func setup(position: CGPoint, size: CGSize = CGSize(width: 60, height: 60)) {
        self.position = position
        self.name = "iceBlock"
        self.zPosition = 2
        self.health = Int(size.width / 30)
        self.maxHealth = max(1, self.health)

        let rect = CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2),
                           size: size)
        iceShape = SKShapeNode(rect: rect, cornerRadius: 4)
        iceShape.fillColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 0.85)
        iceShape.strokeColor = UIColor(red: 0.5, green: 0.75, blue: 0.95, alpha: 1.0)
        iceShape.lineWidth = 2
        addChild(iceShape)

        let shine = SKShapeNode(rect: CGRect(x: -size.width / 2 + 4,
                                              y: size.height / 2 - 10,
                                              width: size.width * 0.3,
                                              height: 6),
                                 cornerRadius: 3)
        shine.fillColor = UIColor.white.withAlphaComponent(0.6)
        shine.strokeColor = .clear
        addChild(shine)

        cracksLayer = SKNode()
        addChild(cracksLayer)

        let physics = SKPhysicsBody(rectangleOf: size)
        physics.isDynamic = false
        physics.restitution = 0.3
        physics.friction = 0.05
        physics.categoryBitMask = PhysicsCategories.ice
        physics.contactTestBitMask = PhysicsCategories.animal
        physics.collisionBitMask = PhysicsCategories.animal
        self.physicsBody = physics
    }

    func takeDamage(amount: Int = 1, fromGroundSlam: Bool = false) {
        guard !broken else { return }

        if fromGroundSlam {
            health = 0
        } else {
            health -= amount
        }

        if health > 0 {
            addCracks(level: maxHealth - health)
            HapticManager.shared.lightImpact()
            SoundManager.shared.playSound("ice_break")
            onCrack?()
        }

        if health <= 0 {
            breakIce()
        }
    }

    private func addCracks(level: Int) {
        cracksLayer.removeAllChildren()

        for _ in 0..<min(level * 2, 6) {
            let crackPath = CGMutablePath()
            let startX = CGFloat(arc4random_uniform(UInt32(frame.width))) - frame.width / 2
            let startY = CGFloat(arc4random_uniform(UInt32(frame.height))) - frame.height / 2

            crackPath.move(to: CGPoint(x: startX, y: startY))
            var currentX = startX
            var currentY = startY

            for _ in 0..<Int(2 + arc4random_uniform(3)) {
                currentX += CGFloat(arc4random_uniform(12)) - 6
                currentY += CGFloat(arc4random_uniform(12)) - 6
                crackPath.addLine(to: CGPoint(x: currentX, y: currentY))
            }

            let crack = SKShapeNode(path: crackPath)
            crack.strokeColor = UIColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 0.8)
            crack.lineWidth = CGFloat(1 + arc4random_uniform(2))
            crack.lineCap = .round
            cracksLayer.addChild(crack)
        }
    }

    private func breakIce() {
        broken = true
        physicsBody = nil

        HapticManager.shared.heavyImpact()
        SoundManager.shared.playSound("ice_break")

        let fade = SKAction.fadeOut(withDuration: 0.2)
        let scale = SKAction.scale(to: 0.8, duration: 0.2)
        iceShape.run(SKAction.sequence([SKAction.group([fade, scale]), SKAction.removeFromParent()]))
        cracksLayer.run(SKAction.sequence([fade, SKAction.removeFromParent()]))

        showBreakParticles()

        onBreak?()
    }

    private func showBreakParticles() {
        for _ in 0..<15 {
            let shardSize = 4 + CGFloat(arc4random_uniform(6))
            let shard = SKShapeNode(rectOf: CGSize(width: shardSize, height: shardSize),
                                     cornerRadius: 1)
            shard.fillColor = UIColor(red: 0.7 + CGFloat(arc4random_uniform(3)) / 10,
                                       green: 0.85 + CGFloat(arc4random_uniform(2)) / 10,
                                       blue: 1.0,
                                       alpha: 0.9)
            shard.strokeColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0)
            shard.lineWidth = 0.5
            shard.position = CGPoint(
                x: CGFloat(arc4random_uniform(UInt32(frame.width))) - frame.width / 2,
                y: CGFloat(arc4random_uniform(UInt32(frame.height))) - frame.height / 2
            )
            shard.zRotation = CGFloat(arc4random_uniform(628)) / 100
            shard.zPosition = 20
            addChild(shard)

            let dx = CGFloat(arc4random_uniform(120)) - 60
            let dy = CGFloat(arc4random_uniform(80)) - 20
            let rot = CGFloat(arc4random_uniform(628)) / 100 - 3.14
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.6)
            let rotate = SKAction.rotate(byAngle: rot, duration: 0.6)
            let fade = SKAction.fadeOut(withDuration: 0.6)
            shard.run(SKAction.sequence([SKAction.group([move, rotate, fade]), SKAction.removeFromParent()]))
        }
    }

    func reset() {
        broken = false
        health = maxHealth
        cracksLayer.removeAllChildren()
        iceShape.removeFromParent()
        let size = self.frame.size
        let rect = CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2),
                           size: size)
        let newShape = SKShapeNode(rect: rect, cornerRadius: 4)
        newShape.fillColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 0.85)
        newShape.strokeColor = UIColor(red: 0.5, green: 0.75, blue: 0.95, alpha: 1.0)
        newShape.lineWidth = 2
        iceShape = newShape
        addChild(iceShape)
        addCracks(level: 0)

        if physicsBody == nil {
            let physics = SKPhysicsBody(rectangleOf: size)
            physics.isDynamic = false
            physics.restitution = 0.3
            physics.friction = 0.05
            physics.categoryBitMask = PhysicsCategories.ice
            physics.contactTestBitMask = PhysicsCategories.animal
            physics.collisionBitMask = PhysicsCategories.animal
            self.physicsBody = physics
        }
    }
}
