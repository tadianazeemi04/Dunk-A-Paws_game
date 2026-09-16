import Foundation
import SpriteKit

class StarNode: SKNode {
    private var starShape: SKShapeNode!
    private var glowShape: SKShapeNode!
    private var particles: SKEmitterNode?

    var collected: Bool = false
    var onCollected: (() -> Void)?
    var starIndex: Int = 0

    func setup(position: CGPoint, size: CGFloat = 20) {
        self.position = position
        self.name = "star"
        self.zPosition = 6

        starShape = SKShapeNode(path: starPath(size: size))
        starShape.fillColor = UIColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
        starShape.strokeColor = UIColor(red: 0.9, green: 0.6, blue: 0.1, alpha: 1.0)
        starShape.lineWidth = 2
        starShape.glowWidth = 3
        addChild(starShape)

        glowShape = SKShapeNode(circleOfRadius: size * 1.2)
        glowShape.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.4, alpha: 0.2)
        glowShape.strokeColor = .clear
        glowShape.zPosition = -1
        addChild(glowShape)

        let physics = SKPhysicsBody(circleOfRadius: size * 0.9)
        physics.isDynamic = false
        physics.categoryBitMask = PhysicsCategories.star
        physics.contactTestBitMask = PhysicsCategories.animal
        physics.collisionBitMask = 0
        self.physicsBody = physics

        startAnimations()
    }

    private func starPath(size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let pointsPerSide = 5
        let center = CGPoint.zero
        var angle: CGFloat = -.pi / 2

        for i in 0..<pointsPerSide * 2 {
            let radius = i % 2 == 0 ? size : size * 0.45
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            angle += .pi / CGFloat(pointsPerSide)
        }
        path.closeSubpath()
        return path
    }

    private func startAnimations() {
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 6)
        starShape.run(SKAction.repeatForever(rotate))

        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 1.0),
            SKAction.fadeAlpha(to: 0.15, duration: 1.0)
        ])
        glowShape.run(SKAction.repeatForever(pulse))

        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.6),
            SKAction.scale(to: 1.0, duration: 0.6)
        ])
        starShape.run(SKAction.repeatForever(bounce))
    }

    func collect() {
        guard !collected else { return }
        collected = true

        starShape.removeAllActions()
        glowShape.removeAllActions()

        HapticManager.shared.starCollect()
        SoundManager.shared.playSound("star_collect")

        let scaleUp = SKAction.scale(to: 1.8, duration: 0.15)
        let fade = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleUp, fade])
        starShape.run(SKAction.sequence([group, SKAction.removeFromParent()]))
        glowShape.run(SKAction.sequence([fade, SKAction.removeFromParent()]))

        showCollectParticles()
        physicsBody = nil

        onCollected?()
    }

    private func showCollectParticles() {
        let texture = makeParticleTexture()
        for burstIndex in 0..<2 {
            let emitter = SKEmitterNode()
            emitter.particleTexture = texture
            emitter.particleBirthRate = 300
            emitter.numParticlesToEmit = burstIndex == 0 ? 12 : 8
            emitter.particleLifetime = 0.6
            emitter.particleLifetimeRange = 0.2
            emitter.particleSpeed = 120
            emitter.particleSpeedRange = 60
            emitter.emissionAngleRange = .pi * 2
            emitter.particleScale = 0.6
            emitter.particleScaleRange = 0.4
            emitter.particleAlphaSpeed = -2.5
            emitter.particleColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
            emitter.particleColorBlendFactor = 1.0
            emitter.zPosition = 50
            addChild(emitter)
            emitter.run(SKAction.sequence([SKAction.wait(forDuration: 0.8), SKAction.removeFromParent()]))
        }
    }

    private func makeParticleTexture() -> SKTexture {
        UIGraphicsBeginImageContext(CGSize(width: 10, height: 10))
        let ctx = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [UIColor.yellow.cgColor, UIColor.orange.cgColor] as CFArray
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil) {
            ctx?.drawRadialGradient(gradient,
                                     startCenter: CGPoint(x: 5, y: 5),
                                     startRadius: 0,
                                     endCenter: CGPoint(x: 5, y: 5),
                                     endRadius: 5,
                                     options: [])
        }
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: img)
    }

    func reset() {
        collected = false
        starShape.removeFromParent()
        glowShape.removeFromParent()
        removeAllChildren()
    }
}
