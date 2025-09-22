//
//  AlertManager.swift
//  ExpressCoach
//
//  Centralized alert and error handling
//

import SwiftUI
import Combine

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissText: String
    let primaryAction: (() -> Void)?
    let primaryActionText: String?

    init(
        title: String,
        message: String,
        dismissText: String = "OK",
        primaryAction: (() -> Void)? = nil,
        primaryActionText: String? = nil
    ) {
        self.title = title
        self.message = message
        self.dismissText = dismissText
        self.primaryAction = primaryAction
        self.primaryActionText = primaryActionText
    }
}

@MainActor
class AlertManager: ObservableObject {
    @Published var alertItem: AlertItem?

    func showError(
        _ error: Error,
        customMessage: String? = nil,
        recovery: (() -> Void)? = nil
    ) {
        let message = customMessage ?? error.localizedDescription

        alertItem = AlertItem(
            title: "Error",
            message: message,
            dismissText: recovery != nil ? "Cancel" : "OK",
            primaryAction: recovery,
            primaryActionText: recovery != nil ? "Retry" : nil
        )

        if AppConstants.HapticFeedback.errorOccurred {
            HapticManager.shared.error()
        }
    }

    func showSuccess(
        title: String = "Success",
        message: String,
        action: (() -> Void)? = nil
    ) {
        alertItem = AlertItem(
            title: title,
            message: message,
            dismissText: "OK",
            primaryAction: action
        )

        if AppConstants.HapticFeedback.saveSuccess {
            HapticManager.shared.success()
        }
    }

    func showValidationError(_ message: String) {
        alertItem = AlertItem(
            title: "Invalid Input",
            message: message,
            dismissText: "OK"
        )

        HapticManager.shared.warning()
    }

    func showDeleteConfirmation(
        itemName: String,
        onDelete: @escaping () -> Void
    ) {
        alertItem = AlertItem(
            title: "Delete \(itemName)?",
            message: "This action cannot be undone.",
            dismissText: "Cancel",
            primaryAction: onDelete,
            primaryActionText: "Delete"
        )

        if AppConstants.HapticFeedback.deleteConfirmation {
            HapticManager.shared.warning()
        }
    }

    func showInfo(
        title: String,
        message: String,
        action: (() -> Void)? = nil
    ) {
        alertItem = AlertItem(
            title: title,
            message: message,
            dismissText: "OK",
            primaryAction: action
        )
    }
}

struct AlertModifier: ViewModifier {
    @ObservedObject var alertManager: AlertManager

    func body(content: Content) -> some View {
        content
            .alert(item: $alertManager.alertItem) { alertItem in
                if let primaryAction = alertItem.primaryAction,
                   let primaryActionText = alertItem.primaryActionText {
                    Alert(
                        title: Text(alertItem.title),
                        message: Text(alertItem.message),
                        primaryButton: .default(Text(primaryActionText), action: primaryAction),
                        secondaryButton: .cancel(Text(alertItem.dismissText))
                    )
                } else {
                    Alert(
                        title: Text(alertItem.title),
                        message: Text(alertItem.message),
                        dismissButton: .default(Text(alertItem.dismissText), action: alertItem.primaryAction)
                    )
                }
            }
    }
}

extension View {
    func withAlertManager(_ alertManager: AlertManager) -> some View {
        modifier(AlertModifier(alertManager: alertManager))
    }
}