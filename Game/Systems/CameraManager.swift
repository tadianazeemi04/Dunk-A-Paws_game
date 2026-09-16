import Foundation
import SpriteKit

class CameraManager {
    weak var camera: SKCameraNode?
    weak var scene: SKScene?

    private var shakeDuration: TimeInterval = 0
    private var shakeIntensity: CGFloat = 0
    private var shakeFrequency: CGFloat = 0
    private var shakeElapsed: TimeInterval = 0
    private var originalPosition: CGPoint = .zero

    private var followTarget: SKNode?
    private var followEnabled: Bool = false
    private var followSmoothness: CGFloat = 0.15

    func setup(camera: SKCameraNode, scene: SKScene) {
        self.camera = camera
        self.scene = scene
        self.originalPosition = camera.position
    }

    func setPosition(_ position: CGPoint) {
        camera?.position = position
        originalPosition = position
    }

    func shake(duration: TimeInterval, intensity: CGFloat = 10, frequency: CGFloat = 0.02) {
        shakeDuration = duration
        shakeIntensity = intensity
        shakeFrequency = frequency
        shakeElapsed = 0
    }

    func startFollowing(_ node: SKNode, smoothness: CGFloat = 0.15) {
        // Kept empty to ensure the court remains stable and the whole screen does not shift
    }

    func stopFollowing() {
        followEnabled = false
        followTarget = nil
    }

    func update(_ currentTime: TimeInterval, deltaTime: TimeInterval) {
        guard let camera = camera else { return }

        if shakeDuration > 0 {
            shakeElapsed += deltaTime
            if shakeElapsed >= shakeDuration {
                shakeDuration = 0
                camera.position = originalPosition
                return
            }

            let progress = shakeElapsed / shakeDuration
            let dampening = 1.0 - CGFloat(progress)
            let offsetX = CGFloat.random(in: -1...1) * shakeIntensity * dampening
            let offsetY = CGFloat.random(in: -1...1) * shakeIntensity * dampening
            camera.position = CGPoint(x: originalPosition.x + offsetX, y: originalPosition.y + offsetY)
        } else {
            camera.position = originalPosition
        }
    }

    func reset() {
        shakeDuration = 0
        followEnabled = false
        followTarget = nil
        camera?.position = originalPosition
    }
}
