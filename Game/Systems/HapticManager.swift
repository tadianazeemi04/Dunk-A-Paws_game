import Foundation
import UIKit
import CoreHaptics

class HapticManager {
    static let shared = HapticManager()

    private var impactGeneratorLight: UIImpactFeedbackGenerator?
    private var impactGeneratorMedium: UIImpactFeedbackGenerator?
    private var impactGeneratorHeavy: UIImpactFeedbackGenerator?
    private var notificationGenerator: UINotificationFeedbackGenerator?
    private var selectionGenerator: UISelectionFeedbackGenerator?
    private var engine: CHHapticEngine?

    private init() {
        prepareGenerators()
        prepareHapticEngine()
    }

    private func prepareGenerators() {
        impactGeneratorLight = UIImpactFeedbackGenerator(style: .light)
        impactGeneratorMedium = UIImpactFeedbackGenerator(style: .medium)
        impactGeneratorHeavy = UIImpactFeedbackGenerator(style: .heavy)
        notificationGenerator = UINotificationFeedbackGenerator()
        selectionGenerator = UISelectionFeedbackGenerator()

        impactGeneratorLight?.prepare()
        impactGeneratorMedium?.prepare()
        impactGeneratorHeavy?.prepare()
        notificationGenerator?.prepare()
        selectionGenerator?.prepare()
    }

    private func prepareHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine error: \(error)")
        }
    }

    private var hapticsEnabled: Bool {
        GameProgressManager.shared.hapticsEnabled
    }

    func lightImpact() {
        guard hapticsEnabled else { return }
        impactGeneratorLight?.impactOccurred()
        impactGeneratorLight?.prepare()
    }

    func mediumImpact() {
        guard hapticsEnabled else { return }
        impactGeneratorMedium?.impactOccurred()
        impactGeneratorMedium?.prepare()
    }

    func heavyImpact() {
        guard hapticsEnabled else { return }
        impactGeneratorHeavy?.impactOccurred()
        impactGeneratorHeavy?.prepare()
    }

    func success() {
        guard hapticsEnabled else { return }
        notificationGenerator?.notificationOccurred(.success)
    }

    func warning() {
        guard hapticsEnabled else { return }
        notificationGenerator?.notificationOccurred(.warning)
    }

    func error() {
        guard hapticsEnabled else { return }
        notificationGenerator?.notificationOccurred(.error)
    }

    func selection() {
        guard hapticsEnabled else { return }
        selectionGenerator?.selectionChanged()
    }

    func customIntensity(intensity: Float, sharpness: Float, duration: Double = 0.1) {
        guard hapticsEnabled, let engine = engine else { return }
        do {
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0,
                duration: duration
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Custom haptic error: \(error)")
        }
    }

    func groundSlam() {
        guard hapticsEnabled else { return }
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.mediumImpact()
        }
    }

    func trampolineBounce() {
        guard hapticsEnabled else { return }
        mediumImpact()
        customIntensity(intensity: 0.6, sharpness: 0.8, duration: 0.15)
    }

    func swish() {
        guard hapticsEnabled else { return }
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.lightImpact()
        }
    }

    func starCollect() {
        lightImpact()
    }
}
