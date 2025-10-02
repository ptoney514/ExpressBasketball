//
//  NotificationTestView.swift
//  ExpressUnited
//
//  Created for Express Basketball - Notification Testing
//

import SwiftUI
import UserNotifications

struct NotificationTestView: View {
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var pushManager = PushNotificationManager.shared
    @State private var testMessage = ""
    @State private var showingAlert = false

    var body: some View {
        List {
            // MARK: - Authorization Status
            Section("Authorization Status") {
                HStack {
                    Text("Status")
                    Spacer()
                    statusBadge
                }

                if !notificationService.isAuthorized {
                    Button("Request Permission") {
                        notificationService.requestAuthorization()
                    }
                    .buttonStyle(.borderedProminent)
                }

                HStack {
                    Text("Device Token")
                    Spacer()
                    if let token = pushManager.deviceToken {
                        Text(String(token.prefix(20)) + "...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Not registered")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // MARK: - Quick Tests (5 second delay)
            Section("Quick Tests (5 seconds)") {
                Button {
                    sendTestNotification(
                        title: "Test Notification",
                        body: "This is a basic test notification",
                        delay: 5
                    )
                } label: {
                    Label("Basic Notification", systemImage: "bell.fill")
                }

                Button {
                    sendTestNotification(
                        title: "Game Reminder",
                        body: "Game vs Warriors starts in 2 hours at Main Gym",
                        delay: 5,
                        category: "GAME_REMINDER"
                    )
                } label: {
                    Label("Game Reminder", systemImage: "sportscourt.fill")
                }

                Button {
                    sendTestNotification(
                        title: "Practice Reminder",
                        body: "Practice starts in 1 hour at Training Center",
                        delay: 5,
                        category: "PRACTICE_REMINDER"
                    )
                } label: {
                    Label("Practice Reminder", systemImage: "figure.basketball")
                }

                Button {
                    sendTestNotification(
                        title: "Important Announcement",
                        body: "Team meeting scheduled for this Saturday at 3pm",
                        delay: 5,
                        category: "ANNOUNCEMENT",
                        sound: .defaultCritical
                    )
                } label: {
                    Label("Urgent Announcement", systemImage: "megaphone.fill")
                }

                Button {
                    sendTestNotification(
                        title: "Schedule Change",
                        body: "Tomorrow's game has been moved to 6pm",
                        delay: 5,
                        category: "SCHEDULE_CHANGE"
                    )
                } label: {
                    Label("Schedule Change", systemImage: "calendar.badge.exclamationmark")
                }
            }

            // MARK: - Immediate Tests
            Section("Immediate Tests (1 second)") {
                Button {
                    sendTestNotification(
                        title: "Immediate Test",
                        body: "This notification fires immediately",
                        delay: 1
                    )
                } label: {
                    Label("Immediate Notification", systemImage: "bolt.fill")
                }
            }

            // MARK: - Notification Management
            Section("Notification Management") {
                Button {
                    checkPendingNotifications()
                } label: {
                    Label("Check Pending Notifications", systemImage: "list.bullet")
                }

                Button(role: .destructive) {
                    cancelAllNotifications()
                } label: {
                    Label("Cancel All Pending", systemImage: "trash.fill")
                }
            }

            // MARK: - Badge Tests
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("App Icon Badge (Home Screen)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Note: Badge only visible on physical device, not simulator")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

                Button {
                    setBadgeCount(1)
                } label: {
                    Label("Set Badge to 1", systemImage: "1.circle.fill")
                }

                Button {
                    setBadgeCount(5)
                } label: {
                    Label("Set Badge to 5", systemImage: "5.circle.fill")
                }

                Button {
                    pushManager.clearBadgeCount()
                } label: {
                    Label("Clear Badge", systemImage: "circle")
                }
            } header: {
                Text("Badge Tests")
            }

            // MARK: - Push Notification Simulation
            Section("Push Notification Simulation") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Simulate remote push notification")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button {
                        simulateRemotePush()
                    } label: {
                        Label("Simulate Remote Push", systemImage: "antenna.radiowaves.left.and.right")
                    }
                }
            }

            // MARK: - Test Result
            if !testMessage.isEmpty {
                Section("Test Result") {
                    Text(testMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Notification Testing")
        .alert("Pending Notifications", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(testMessage)
        }
    }

    // MARK: - Status Badge
    private var statusBadge: some View {
        Group {
            if notificationService.isAuthorized {
                Label("Authorized", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Label("Not Authorized", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .font(.caption)
    }

    // MARK: - Helper Methods

    private func sendTestNotification(
        title: String,
        body: String,
        delay: TimeInterval,
        category: String = "",
        sound: UNNotificationSound = .default
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound

        if !category.isEmpty {
            content.categoryIdentifier = category
        }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: delay,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    testMessage = "Error: \(error.localizedDescription)"
                } else {
                    testMessage = "✅ Scheduled '\(title)' in \(Int(delay)) seconds"
                }
            }
        }
    }

    private func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                if requests.isEmpty {
                    testMessage = "No pending notifications"
                } else {
                    testMessage = "Found \(requests.count) pending notification(s):\n" +
                        requests.map { "• \($0.content.title)" }.joined(separator: "\n")
                }
                showingAlert = true
            }
        }
    }

    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        testMessage = "✅ All pending notifications cancelled"
    }

    private func setBadgeCount(_ count: Int) {
        Task { @MainActor in
            if #available(iOS 16.0, *) {
                UNUserNotificationCenter.current().setBadgeCount(count)
            } else {
                UIApplication.shared.applicationIconBadgeNumber = count
            }
            testMessage = "✅ Badge set to \(count)"
        }
    }

    private func simulateRemotePush() {
        // Simulate receiving a remote push notification
        let userInfo: [AnyHashable: Any] = [
            "type": "announcement",
            "title": "Simulated Push",
            "body": "This simulates a remote push notification",
            "aps": [
                "alert": [
                    "title": "Simulated Push",
                    "body": "This simulates a remote push notification"
                ],
                "badge": 1,
                "sound": "default"
            ]
        ]

        pushManager.handleRemoteNotification(userInfo: userInfo)
        testMessage = "✅ Simulated remote push notification"
    }
}

#Preview {
    NavigationStack {
        NotificationTestView()
    }
}
