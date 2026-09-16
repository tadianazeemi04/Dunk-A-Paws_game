import Foundation
import SpriteKit
import CoreGraphics

class TrajectoryRenderer {
    private var dotNodes: [SKShapeNode] = []
    private let maxDots = 24
    private let dotRadius: CGFloat = 4

    weak var parent: SKNode?

    func setup(in parent: SKNode) {
        self.parent = parent
        createDots()
        hide()
    }

    private func createDots() {
        dotNodes.forEach { $0.removeFromParent() }
        dotNodes.removeAll()

        for i in 0..<maxDots {
            let dot = SKShapeNode(circleOfRadius: dotRadius)
            dot.fillColor = .white
            dot.strokeColor = .white
            dot.lineWidth = 0
            dot.alpha = 1.0 - CGFloat(i) / CGFloat(maxDots)
            dot.zPosition = 5
            dot.isHidden = true
            dotNodes.append(dot)
            parent?.addChild(dot)
        }
    }

    func show() {
        dotNodes.forEach { $0.isHidden = false }
    }

    func hide() {
        dotNodes.forEach { $0.isHidden = true }
    }

    func update(startPosition: CGPoint, velocity: CGVector, gravity: CGFloat) {
        guard velocity.dx != 0 || velocity.dy != 0 else {
            hide()
            return
        }
        show()

        let timeStep: CGFloat = 0.055

        for i in 0..<maxDots {
            let t = CGFloat(i + 1) * timeStep
            let px = startPosition.x + velocity.dx * t
            let py = startPosition.y + velocity.dy * t + 0.5 * gravity * t * t

            let dot = dotNodes[i]

            if py < 70 && i > 3 {
                dot.isHidden = true
                continue
            }
            dot.isHidden = false
            dot.position = CGPoint(x: px, y: py)

            let scale = 1.0 - CGFloat(i) / CGFloat(maxDots) * 0.5
            dot.setScale(scale)

            if i < 3 {
                dot.fillColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
            } else {
                let alpha = 1.0 - CGFloat(i) / CGFloat(maxDots) * 0.65
                dot.fillColor = UIColor.white.withAlphaComponent(alpha)
            }
            dot.strokeColor = dot.fillColor
        }
    }

    func highlightNearHoop(_ hoopPosition: CGPoint, threshold: CGFloat = 80) {
        for dot in dotNodes {
            let dist = hypot(dot.position.x - hoopPosition.x, dot.position.y - hoopPosition.y)
            if dist < threshold {
                let glow = UIColor(red: 0.3, green: 1.0, blue: 0.4, alpha: 1.0)
                dot.fillColor = glow
                dot.strokeColor = glow
                dot.glowWidth = 4
            }
        }
    }

    func clearGlow() {
        dotNodes.forEach { $0.glowWidth = 0 }
    }
}

extension CGVector {
    var length: CGFloat {
        sqrt(dx * dx + dy * dy)
    }
}
