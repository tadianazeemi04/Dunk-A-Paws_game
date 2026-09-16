import Foundation
import SpriteKit
import SwiftUI

class AnimalNode: SKSpriteNode {
    var type: AnimalType = .cat
    var abilityUsed: Bool = false
    var isAiming: Bool = false
    var animationState: String = "idle"
    var hitRim: Bool = false
    var hitBackboard: Bool = false
    var hitTrampoline: Bool = false
    var hitFan: Bool = false
    var usedIceSlam: Bool = false
    var rotationSpeed: CGFloat = 0
    var onAbilityUsed: (() -> Void)?
    var onCollision: ((CollisionType) -> Void)?

    enum CollisionType {
        case rim, backboard, ground, trampoline, ice, water, boundary
    }

    private var bodyShape: SKShapeNode!
    private var faceContainer: SKNode!
    private var earsContainer: SKNode!
    private var abilityEffectNode: SKEmitterNode?

    func configure(type: AnimalType, radius: CGFloat = 24) {
        self.type = type
        self.size = CGSize(width: radius * 2, height: radius * 2)
        self.name = "animal"

        setupPhysicsBody(radius: radius)
        setupVisual(radius: radius)
    }

    private func setupPhysicsBody(radius: CGFloat) {
        let physicsBody = SKPhysicsBody(circleOfRadius: radius - 2)
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = true
        physicsBody.allowsRotation = true
        physicsBody.mass = type.mass
        physicsBody.restitution = type.bounce
        physicsBody.friction = type.friction
        physicsBody.linearDamping = 0.1
        physicsBody.angularDamping = 0.5
        physicsBody.categoryBitMask = PhysicsCategories.animal
        physicsBody.contactTestBitMask = PhysicsCategories.rim | PhysicsCategories.backboard |
                                        PhysicsCategories.ground | PhysicsCategories.trampoline |
                                        PhysicsCategories.ice | PhysicsCategories.star |
                                        PhysicsCategories.boundary | PhysicsCategories.scoringSensor |
                                        PhysicsCategories.fan | PhysicsCategories.water | PhysicsCategories.net
        physicsBody.collisionBitMask = PhysicsCategories.rim | PhysicsCategories.backboard |
                                       PhysicsCategories.ground | PhysicsCategories.trampoline |
                                       PhysicsCategories.ice | PhysicsCategories.boundary | PhysicsCategories.net
        self.physicsBody = physicsBody
    }

    private func setupVisual(radius: CGFloat) {
        bodyShape = SKShapeNode(circleOfRadius: radius - 1)
        bodyShape.fillColor = UIColor(type.bodyColor)
        bodyShape.strokeColor = UIColor(type.accentColor).withAlphaComponent(0.5)
        bodyShape.lineWidth = 2
        addChild(bodyShape)

        earsContainer = SKNode()
        addChild(earsContainer)
        drawEars(radius: radius)

        faceContainer = SKNode()
        addChild(faceContainer)
        drawFace(radius: radius)

        drawBodyDetails(radius: radius)
    }

    private func drawEars(radius: CGFloat) {
        earsContainer.removeAllChildren()

        switch type {
        case .panda:
            let earSize = radius * 0.35
            let leftEar = SKShapeNode(circleOfRadius: earSize)
            leftEar.fillColor = .black
            leftEar.strokeColor = .black
            leftEar.position = CGPoint(x: -radius * 0.55, y: radius * 0.65)
            earsContainer.addChild(leftEar)

            let rightEar = SKShapeNode(circleOfRadius: earSize)
            rightEar.fillColor = .black
            rightEar.strokeColor = .black
            rightEar.position = CGPoint(x: radius * 0.55, y: radius * 0.65)
            earsContainer.addChild(rightEar)

        case .cat:
            let earPath = CGMutablePath()
            earPath.move(to: CGPoint(x: -radius * 0.35, y: radius * 0.4))
            earPath.addLine(to: CGPoint(x: -radius * 0.15, y: radius * 0.85))
            earPath.addLine(to: CGPoint(x: 0, y: radius * 0.5))
            earPath.closeSubpath()

            let leftEar = SKShapeNode(path: earPath)
            leftEar.fillColor = UIColor(type.bodyColor)
            leftEar.strokeColor = UIColor(type.accentColor)
            leftEar.lineWidth = 1.5
            earsContainer.addChild(leftEar)

            let rightEarPath = CGMutablePath()
            rightEarPath.move(to: CGPoint(x: radius * 0.35, y: radius * 0.4))
            rightEarPath.addLine(to: CGPoint(x: radius * 0.15, y: radius * 0.85))
            rightEarPath.addLine(to: CGPoint(x: 0, y: radius * 0.5))
            rightEarPath.closeSubpath()

            let rightEar = SKShapeNode(path: rightEarPath)
            rightEar.fillColor = UIColor(type.bodyColor)
            rightEar.strokeColor = UIColor(type.accentColor)
            rightEar.lineWidth = 1.5
            earsContainer.addChild(rightEar)

        case .penguin:
            let leftEye = SKShapeNode(circleOfRadius: radius * 0.12)
            leftEye.fillColor = UIColor(type.accentColor)
            leftEye.position = CGPoint(x: -radius * 0.4, y: radius * 0.6)
            earsContainer.addChild(leftEye)
            let rightEye = leftEye.copy() as! SKShapeNode
            rightEye.position = CGPoint(x: radius * 0.4, y: radius * 0.6)
            earsContainer.addChild(rightEye)

        case .otter:
            let earSize = radius * 0.18
            let leftEar = SKShapeNode(circleOfRadius: earSize)
            leftEar.fillColor = UIColor(type.accentColor)
            leftEar.position = CGPoint(x: -radius * 0.6, y: radius * 0.55)
            earsContainer.addChild(leftEar)
            let rightEar = leftEar.copy() as! SKShapeNode
            rightEar.position = CGPoint(x: radius * 0.6, y: radius * 0.55)
            earsContainer.addChild(rightEar)
        }
    }

    private func drawFace(radius: CGFloat) {
        faceContainer.removeAllChildren()

        let eyeSize = radius * 0.1
        let eyeY = radius * 0.15
        let eyeX = radius * 0.28

        if type == .panda {
            let patchSize = radius * 0.28
            let leftPatch = SKShapeNode(ellipseOf: CGSize(width: patchSize * 1.1, height: patchSize * 1.4))
            leftPatch.fillColor = .black
            leftPatch.position = CGPoint(x: -eyeX, y: eyeY)
            leftPatch.zRotation = -0.3
            faceContainer.addChild(leftPatch)

            let rightPatch = SKShapeNode(ellipseOf: CGSize(width: patchSize * 1.1, height: patchSize * 1.4))
            rightPatch.fillColor = .black
            rightPatch.position = CGPoint(x: eyeX, y: eyeY)
            rightPatch.zRotation = 0.3
            faceContainer.addChild(rightPatch)
        }

        if type != .penguin {
            let leftEye = SKShapeNode(circleOfRadius: eyeSize)
            leftEye.fillColor = .black
            leftEye.position = CGPoint(x: -eyeX, y: eyeY)
            faceContainer.addChild(leftEye)

            let rightEye = SKShapeNode(circleOfRadius: eyeSize)
            rightEye.fillColor = .black
            rightEye.position = CGPoint(x: eyeX, y: eyeY)
            faceContainer.addChild(rightEye)

            let leftShine = SKShapeNode(circleOfRadius: eyeSize * 0.35)
            leftShine.fillColor = .white
            leftShine.position = CGPoint(x: -eyeX + eyeSize * 0.3, y: eyeY + eyeSize * 0.3)
            faceContainer.addChild(leftShine)
            let rightShine = leftShine.copy() as! SKShapeNode
            rightShine.position = CGPoint(x: eyeX + eyeSize * 0.3, y: eyeY + eyeSize * 0.3)
            faceContainer.addChild(rightShine)
        }

        drawNoseAndMouth(radius: radius)
    }

    private func drawNoseAndMouth(radius: CGFloat) {
        let noseY = -radius * 0.05
        let noseSize = radius * 0.12

        switch type {
        case .panda:
            let nose = SKShapeNode(ellipseOf: CGSize(width: noseSize * 1.5, height: noseSize))
            nose.fillColor = .black
            nose.position = CGPoint(x: 0, y: noseY)
            faceContainer.addChild(nose)

        case .cat, .otter:
            let nosePath = CGMutablePath()
            nosePath.move(to: CGPoint(x: -noseSize, y: noseY))
            nosePath.addLine(to: CGPoint(x: noseSize, y: noseY))
            nosePath.addLine(to: CGPoint(x: 0, y: noseY - noseSize))
            nosePath.closeSubpath()
            let nose = SKShapeNode(path: nosePath)
            nose.fillColor = UIColor(type.accentColor)
            nose.strokeColor = UIColor(type.accentColor)
            faceContainer.addChild(nose)

        case .penguin:
            let beakPath = CGMutablePath()
            beakPath.move(to: CGPoint(x: -radius * 0.22, y: radius * 0.15))
            beakPath.addLine(to: CGPoint(x: radius * 0.22, y: radius * 0.15))
            beakPath.addLine(to: CGPoint(x: 0, y: -radius * 0.08))
            beakPath.closeSubpath()
            let beak = SKShapeNode(path: beakPath)
            beak.fillColor = UIColor.orange
            beak.strokeColor = UIColor.orange
            faceContainer.addChild(beak)
        }

        let mouthY = (type == .penguin) ? -radius * 0.2 : -radius * 0.25
        let mouthPath = CGMutablePath()
        mouthPath.move(to: CGPoint(x: -radius * 0.18, y: mouthY))
        mouthPath.addQuadCurve(to: CGPoint(x: 0, y: mouthY - radius * 0.08),
                               control: CGPoint(x: -radius * 0.09, y: mouthY - radius * 0.08))
        mouthPath.addQuadCurve(to: CGPoint(x: radius * 0.18, y: mouthY),
                               control: CGPoint(x: radius * 0.09, y: mouthY - radius * 0.08))
        let mouth = SKShapeNode(path: mouthPath)
        mouth.strokeColor = (type == .panda) ? .black : UIColor(type.accentColor)
        mouth.lineWidth = 2
        mouth.lineCap = .round
        mouth.fillColor = .clear
        faceContainer.addChild(mouth)
    }

    private func drawBodyDetails(radius: CGFloat) {
        switch type {
        case .penguin:
            let bellyPath = CGPath(ellipseIn: CGRect(x: -radius * 0.55, y: -radius * 0.7,
                                                      width: radius * 1.1, height: radius * 1.1),
                                    transform: nil)
            let belly = SKShapeNode(path: bellyPath)
            belly.fillColor = .white
            belly.strokeColor = .clear
            belly.zPosition = -1
            addChild(belly)

        case .otter:
            let tailPath = CGMutablePath()
            tailPath.move(to: CGPoint(x: -radius * 0.9, y: -radius * 0.2))
            tailPath.addQuadCurve(to: CGPoint(x: -radius * 1.2, y: -radius * 0.5),
                                   control: CGPoint(x: -radius * 1.2, y: -radius * 0.1))
            tailPath.addQuadCurve(to: CGPoint(x: -radius * 0.9, y: -radius * 0.1),
                                   control: CGPoint(x: -radius * 1.0, y: -radius * 0.35))
            let tail = SKShapeNode(path: tailPath)
            tail.fillColor = UIColor(type.accentColor)
            tail.strokeColor = .clear
            tail.zPosition = -1
            addChild(tail)

        default:
            break
        }
    }

    func useCatAbility() {
        guard type == .cat && !abilityUsed else { return }
        guard let physics = physicsBody else { return }

        abilityUsed = true
        let currentVel = physics.velocity
        let boost = CGVector(dx: -currentVel.dx * 0.15,
                              dy: GamePhysicsConfig.catJumpImpulse)
        physics.applyImpulse(boost)

        let impulse = SKAction.applyImpulse(boost, duration: 0.1)
        run(impulse)

        showAbilityEffect(color: .systemOrange)
        HapticManager.shared.mediumImpact()
        SoundManager.shared.playSound("ability")
        onAbilityUsed?()
    }

    private func showAbilityEffect(color: UIColor) {
        let effect = SKEmitterNode()
        effect.particleTexture = SKTexture(image: makeCircleImage(size: 8, color: color))
        effect.particleBirthRate = 200
        effect.numParticlesToEmit = 15
        effect.particleLifetime = 0.5
        effect.particleSpeed = 150
        effect.particleSpeedRange = 80
        effect.emissionAngleRange = .pi * 2
        effect.particleScale = 1
        effect.particleScaleRange = 0.5
        effect.particleAlphaSpeed = -2
        addChild(effect)
        abilityEffectNode = effect
        effect.run(SKAction.sequence([SKAction.wait(forDuration: 0.6), SKAction.removeFromParent()]))
    }

    private func makeCircleImage(size: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }

    func resetForNewShot() {
        abilityUsed = false
        hitRim = false
        hitBackboard = false
        hitTrampoline = false
        hitFan = false
        usedIceSlam = false
        physicsBody?.isDynamic = false
        physicsBody?.velocity = .zero
        physicsBody?.angularVelocity = 0
        zRotation = 0
        isHidden = false
    }

    func squish() {
        let scaleDown = SKAction.scaleX(to: 1.15, y: 0.85, duration: 0.08)
        let scaleUp = SKAction.scaleX(to: 0.95, y: 1.08, duration: 0.08)
        let normalize = SKAction.scale(to: 1.0, duration: 0.08)
        run(SKAction.sequence([scaleDown, scaleUp, normalize]))
    }

    func bounceAnimation() {
        squish()
    }
}
