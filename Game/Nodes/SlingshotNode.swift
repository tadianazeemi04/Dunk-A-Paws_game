import Foundation
import SpriteKit

class SlingshotNode: SKNode {
    private var leftBand: SKShapeNode!
    private var rightBand: SKShapeNode!
    private var frameNode: SKNode!
    private var leftYoke: SKShapeNode!
    private var rightYoke: SKShapeNode!
    private var baseNode: SKShapeNode!

    var launchPosition: CGPoint = CGPoint(x: 0, y: 50)
    var leftBandAnchor: CGPoint = CGPoint(x: -20, y: 80)
    var rightBandAnchor: CGPoint = CGPoint(x: 20, y: 80)

    func setup(frameSize: CGSize, position: CGPoint) {
        self.position = position
        launchPosition = CGPoint(x: 0, y: 50)
        leftBandAnchor = CGPoint(x: -22, y: 85)
        rightBandAnchor = CGPoint(x: 22, y: 85)

        setupFrame()
        setupBands()
    }

    private func setupFrame() {
        frameNode = SKNode()
        addChild(frameNode)

        let basePath = CGMutablePath()
        basePath.move(to: CGPoint(x: -35, y: -70))
        basePath.addLine(to: CGPoint(x: -45, y: -85))
        basePath.addLine(to: CGPoint(x: 45, y: -85))
        basePath.addLine(to: CGPoint(x: 35, y: -70))
        basePath.closeSubpath()
        baseNode = SKShapeNode(path: basePath)
        baseNode.fillColor = UIColor(red: 0.45, green: 0.3, blue: 0.15, alpha: 1.0)
        baseNode.strokeColor = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        baseNode.lineWidth = 2
        frameNode.addChild(baseNode)

        let handlePath = CGMutablePath()
        handlePath.move(to: CGPoint(x: -10, y: -70))
        handlePath.addLine(to: CGPoint(x: 0, y: 10))
        handlePath.addLine(to: CGPoint(x: 10, y: -70))
        handlePath.closeSubpath()
        let handle = SKShapeNode(path: handlePath)
        handle.fillColor = UIColor(red: 0.4, green: 0.25, blue: 0.12, alpha: 1.0)
        handle.strokeColor = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        handle.lineWidth = 2
        frameNode.addChild(handle)

        let leftArm = SKShapeNode()
        leftArm.path = makeArmPath(start: CGPoint(x: -5, y: 5), end: leftBandAnchor, width: 14)
        leftArm.fillColor = UIColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
        leftArm.strokeColor = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        leftArm.lineWidth = 2
        frameNode.addChild(leftArm)

        let rightArm = SKShapeNode()
        rightArm.path = makeArmPath(start: CGPoint(x: 5, y: 5), end: rightBandAnchor, width: 14)
        rightArm.fillColor = UIColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
        rightArm.strokeColor = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        rightArm.lineWidth = 2
        frameNode.addChild(rightArm)

        leftYoke = SKShapeNode(circleOfRadius: 6)
        leftYoke.fillColor = UIColor(red: 0.3, green: 0.2, blue: 0.08, alpha: 1.0)
        leftYoke.strokeColor = UIColor(red: 0.15, green: 0.1, blue: 0.04, alpha: 1.0)
        leftYoke.position = leftBandAnchor
        frameNode.addChild(leftYoke)

        rightYoke = SKShapeNode(circleOfRadius: 6)
        rightYoke.fillColor = UIColor(red: 0.3, green: 0.2, blue: 0.08, alpha: 1.0)
        rightYoke.strokeColor = UIColor(red: 0.15, green: 0.1, blue: 0.04, alpha: 1.0)
        rightYoke.position = rightBandAnchor
        frameNode.addChild(rightYoke)
    }

    private func makeArmPath(start: CGPoint, end: CGPoint, width: CGFloat) -> CGPath {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = hypot(dx, dy)
        let nx = -dy / length * width / 2
        let ny = dx / length * width / 2

        let path = CGMutablePath()
        path.move(to: CGPoint(x: start.x + nx, y: start.y + ny))
        path.addLine(to: CGPoint(x: end.x + nx, y: end.y + ny))
        path.addLine(to: CGPoint(x: end.x - nx, y: end.y - ny))
        path.addLine(to: CGPoint(x: start.x - nx, y: start.y - ny))
        path.closeSubpath()
        return path
    }

    private func setupBands() {
        leftBand = SKShapeNode()
        leftBand.strokeColor = UIColor(red: 0.95, green: 0.2, blue: 0.2, alpha: 1.0)
        leftBand.lineWidth = 5
        leftBand.lineCap = .round
        leftBand.zPosition = 1
        frameNode.addChild(leftBand)

        rightBand = SKShapeNode()
        rightBand.strokeColor = UIColor(red: 0.95, green: 0.2, blue: 0.2, alpha: 1.0)
        rightBand.lineWidth = 5
        rightBand.lineCap = .round
        rightBand.zPosition = 1
        frameNode.addChild(rightBand)

        updateBands(to: launchPosition)
    }

    func updateBands(to draggedPosition: CGPoint) {
        let leftPath = CGMutablePath()
        leftPath.move(to: leftBandAnchor)
        leftPath.addLine(to: draggedPosition)
        leftBand.path = leftPath

        let rightPath = CGMutablePath()
        rightPath.move(to: rightBandAnchor)
        rightPath.addLine(to: draggedPosition)
        rightBand.path = rightPath

        let stretch = hypot(draggedPosition.x - launchPosition.x,
                             draggedPosition.y - launchPosition.y) / GamePhysicsConfig.maxPullDistance
        let clampedStretch = min(stretch, 1.0)

        let redComponent: CGFloat = 0.95
        let greenComponent: CGFloat = 0.2 + (1.0 - clampedStretch) * 0.3
        let blueComponent: CGFloat = 0.2
        let bandColor = UIColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)

        leftBand.strokeColor = bandColor
        rightBand.strokeColor = bandColor
        leftBand.lineWidth = 5 + clampedStretch * 3
        rightBand.lineWidth = 5 + clampedStretch * 3
    }

    func resetBands() {
        updateBands(to: launchPosition)

        let snap = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.08)
        ])
        leftBand.run(snap)
        rightBand.run(snap.copy() as! SKAction)
    }

    func snapRelease() {
        let snapLeft = SKAction.sequence([
            SKAction.wait(forDuration: 0.02),
            SKAction.scale(to: 1.1, duration: 0.03),
            SKAction.scale(to: 1.0, duration: 0.08)
        ])
        leftBand.run(snapLeft)
        rightBand.run(snapLeft.copy() as! SKAction)

        showLaunchDust()
    }

    private func showLaunchDust() {
        guard self.scene != nil else { return }

        for _ in 0..<5 {
            let dust = SKShapeNode(circleOfRadius: 4 + CGFloat(arc4random_uniform(4)))
            dust.fillColor = UIColor(white: 0.6, alpha: 0.7)
            dust.strokeColor = .clear
            dust.position = CGPoint(x: launchPosition.x + CGFloat(arc4random_uniform(20)) - 10,
                                    y: launchPosition.y - 10 + CGFloat(arc4random_uniform(10)))
            dust.zPosition = 4
            addChild(dust)

            let dx = CGFloat(arc4random_uniform(40)) - 20
            let dy = CGFloat(arc4random_uniform(30))
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.4)
            let fade = SKAction.fadeOut(withDuration: 0.4)
            let scale = SKAction.scale(to: 1.5, duration: 0.4)
            let group = SKAction.group([move, fade, scale])
            dust.run(SKAction.sequence([group, SKAction.removeFromParent()]))
        }
    }
}
