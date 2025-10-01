//
//  PushNotificationPermissionView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct PushNotificationPermissionView: View {
    @Binding var isPresented: Bool
    let onComplete: () -> Void

    private let pushManager = PushNotificationManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)

                VStack(spacing: 15) {
                    Text("Stay Updated")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Get instant notifications about:")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 20) {
                    NotificationFeatureRow(
                        icon: "sportscourt.fill",
                        title: "Game Updates",
                        description: "Time changes, cancellations, and reminders"
                    )

                    NotificationFeatureRow(
                        icon: "figure.basketball",
                        title: "Practice Alerts",
                        description: "Schedule changes and important reminders"
                    )

                    NotificationFeatureRow(
                        icon: "megaphone.fill",
                        title: "Team Announcements",
                        description: "Important messages from your coach"
                    )

                    NotificationFeatureRow(
                        icon: "calendar.badge.exclamationmark",
                        title: "Schedule Changes",
                        description: "Never miss an update to the team calendar"
                    )
                }
                .padding(.horizontal)

                Spacer()

                VStack(spacing: 15) {
                    Button(action: {
                        requestPushPermission()
                    }) {
                        Text("Enable Notifications")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)

                    Button(action: {
                        skipPermission()
                    }) {
                        Text("Maybe Later")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Text("You can change this anytime in Settings")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func requestPushPermission() {
        pushManager.requestAuthorization { granted in
            if granted {
                print("✅ Push notifications enabled")
            } else {
                print("⚠️ Push notifications denied")
            }

            isPresented = false
            onComplete()
        }
    }

    private func skipPermission() {
        isPresented = false
        onComplete()
    }
}

struct NotificationFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.orange)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    PushNotificationPermissionView(
        isPresented: .constant(true),
        onComplete: {}
    )
}
