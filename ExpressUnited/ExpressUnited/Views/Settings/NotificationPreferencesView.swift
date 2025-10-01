//
//  NotificationPreferencesView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct NotificationPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("gameReminders") private var gameReminders = true
    @AppStorage("practiceReminders") private var practiceReminders = true
    @AppStorage("announcementAlerts") private var announcementAlerts = true
    @AppStorage("scheduleChangeAlerts") private var scheduleChangeAlerts = true

    private let pushManager = PushNotificationManager.shared
    private let supabaseService = SupabaseService.shared

    @State private var isUpdating = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Enable Push Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            } else {
                                syncPreferencesToBackend()
                            }
                        }
                } header: {
                    Text("Push Notifications")
                } footer: {
                    Text("Receive instant alerts on your device when your coach sends updates.")
                }

                if notificationsEnabled {
                    Section {
                        NotificationToggleRow(
                            icon: "sportscourt.fill",
                            title: "Game Reminders",
                            description: "Get notified before games start",
                            isOn: $gameReminders
                        )
                        .onChange(of: gameReminders) { _, _ in
                            syncPreferencesToBackend()
                        }

                        NotificationToggleRow(
                            icon: "figure.basketball",
                            title: "Practice Reminders",
                            description: "Get notified before practices",
                            isOn: $practiceReminders
                        )
                        .onChange(of: practiceReminders) { _, _ in
                            syncPreferencesToBackend()
                        }

                        NotificationToggleRow(
                            icon: "megaphone.fill",
                            title: "Team Announcements",
                            description: "Coach messages and updates",
                            isOn: $announcementAlerts
                        )
                        .onChange(of: announcementAlerts) { _, _ in
                            syncPreferencesToBackend()
                        }

                        NotificationToggleRow(
                            icon: "calendar.badge.exclamationmark",
                            title: "Schedule Changes",
                            description: "Time or location updates",
                            isOn: $scheduleChangeAlerts
                        )
                        .onChange(of: scheduleChangeAlerts) { _, _ in
                            syncPreferencesToBackend()
                        }
                    } header: {
                        Text("Notification Types")
                    } footer: {
                        Text("Choose which types of updates you want to receive.")
                    }
                }

                Section {
                    HStack {
                        Text("Notification Status")
                        Spacer()
                        if pushManager.isRegisteredForRemoteNotifications {
                            Label("Active", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                        } else {
                            Label("Inactive", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }

                    if !pushManager.isRegisteredForRemoteNotifications {
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Label("Open Settings", systemImage: "gear")
                        }
                    }
                } header: {
                    Text("System Status")
                } footer: {
                    if !pushManager.isRegisteredForRemoteNotifications {
                        Text("Notifications are disabled in your device settings. Open Settings to enable them.")
                    }
                }
            }
            .navigationTitle("Push Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if isUpdating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private func requestNotificationPermission() {
        pushManager.requestAuthorization { granted in
            if granted {
                syncPreferencesToBackend()
            }
        }
    }

    private func syncPreferencesToBackend() {
        guard let deviceToken = pushManager.deviceToken else {
            print("⚠️ No device token available to sync preferences")
            return
        }

        isUpdating = true

        let preferences = NotificationPreferences(
            notificationsEnabled: notificationsEnabled,
            gameReminders: gameReminders,
            practiceReminders: practiceReminders,
            announcementAlerts: announcementAlerts,
            scheduleChangeAlerts: scheduleChangeAlerts
        )

        Task {
            do {
                try await supabaseService.updateNotificationPreferences(
                    token: deviceToken,
                    preferences: preferences
                )
                print("✅ Notification preferences synced to backend")
            } catch {
                print("❌ Failed to sync preferences: \(error)")
            }

            await MainActor.run {
                isUpdating = false
            }
        }
    }
}

struct NotificationToggleRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.orange)
                    .frame(width: 24)

                Toggle(title, isOn: $isOn)
            }

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 32)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NotificationPreferencesView()
}
