//
//  HapticManager.swift
//  ExpressCoach
//
//  Haptic feedback controller
//

import UIKit
import CoreHaptics

@MainActor
class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    private let impactFeedback = UIImpactFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    private let selectionFeedback = UISelectionFeedbackGenerator()

    private init() {
        setupHapticEngine()
        impactFeedback.prepare()
        notificationFeedback.prepare()
        selectionFeedback.prepare()
    }

    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine failed to start: \(error)")
        }
    }

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard AppConstants.HapticFeedback.enableHaptics else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func success() {
        guard AppConstants.HapticFeedback.enableHaptics else { return }
        notificationFeedback.notificationOccurred(.success)
    }

    func warning() {
        guard AppConstants.HapticFeedback.enableHaptics else { return }
        notificationFeedback.notificationOccurred(.warning)
    }

    func error() {
        guard AppConstants.HapticFeedback.enableHaptics else { return }
        notificationFeedback.notificationOccurred(.error)
    }

    func selection() {
        guard AppConstants.HapticFeedback.enableHaptics else { return }
        selectionFeedback.selectionChanged()
    }

    func lightImpact() {
        impact(style: .light)
    }

    func mediumImpact() {
        impact(style: .medium)
    }

    func heavyImpact() {
        impact(style: .heavy)
    }

    func customPattern() {
        guard AppConstants.HapticFeedback.enableHaptics,
              CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        var events = [CHHapticEvent]()

        // Create a sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // Create a second lighter tap
        let intensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
        let sharpness2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity2, sharpness2], relativeTime: 0.1)
        events.append(event2)

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play custom haptic pattern: \(error)")
        }
    }

    func deleteConfirmation() {
        guard AppConstants.HapticFeedback.deleteConfirmation else { return }
        warning()
    }

    func saveSuccess() {
        guard AppConstants.HapticFeedback.saveSuccess else { return }
        success()
    }
}