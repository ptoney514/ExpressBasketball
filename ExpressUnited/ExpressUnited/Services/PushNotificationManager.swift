//
//  PushNotificationManager.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import Foundation
import UserNotifications
import UIKit
import Combine

/// Manages push notification registration, device tokens, and remote notification handling
class PushNotificationManager: NSObject, ObservableObject {
    static let shared = PushNotificationManager()

    @Published var deviceToken: String?
    @Published var isRegisteredForRemoteNotifications = false
    @Published var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined

    private let supabaseService = SupabaseService.shared
    private var cancellables = Set<AnyCancellable>()

    override private init() {
        super.init()
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    /// Check current notification authorization status
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationAuthorizationStatus = settings.authorizationStatus
            }
        }
    }

    /// Request push notification permission from user
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound, .criticalAlert]
        ) { [weak self] granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error requesting notification authorization: \(error)")
                    completion?(false)
                    return
                }

                self?.notificationAuthorizationStatus = granted ? .authorized : .denied

                if granted {
                    print("✅ Notification authorization granted")
                    self?.registerForRemoteNotifications()
                    completion?(true)
                } else {
                    print("⚠️ Notification authorization denied")
                    completion?(false)
                }
            }
        }
    }

    // MARK: - Device Token Registration

    /// Register for remote notifications with APNS
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    /// Handle successful device token registration
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        DispatchQueue.main.async {
            self.deviceToken = tokenString
            self.isRegisteredForRemoteNotifications = true
            print("✅ Registered for remote notifications")
            print("📱 Device token: \(tokenString)")

            // Store device token in UserDefaults for persistence
            UserDefaults.standard.set(tokenString, forKey: "deviceToken")

            // Upload token to backend
            self.uploadDeviceTokenToBackend(token: tokenString)
        }
    }

    /// Handle device token registration failure
    func didFailToRegisterForRemoteNotifications(withError error: Error) {
        DispatchQueue.main.async {
            self.isRegisteredForRemoteNotifications = false
            print("❌ Failed to register for remote notifications: \(error)")
        }
    }

    /// Upload device token to Supabase backend
    private func uploadDeviceTokenToBackend(token: String) {
        // Get current team ID from SwiftData
        // This will be called after team code entry
        guard let teamId = getCurrentTeamId() else {
            print("⚠️ No team ID found, device token will be uploaded after team join")
            return
        }

        Task {
            do {
                try await supabaseService.registerDeviceToken(token: token, teamId: teamId)
                print("✅ Device token uploaded to backend")
            } catch {
                print("❌ Failed to upload device token: \(error)")
            }
        }
    }

    /// Register device token for a specific team (called after team join)
    func registerDeviceTokenForTeam(teamId: UUID) {
        guard let token = deviceToken else {
            print("⚠️ No device token available to register")
            return
        }

        Task {
            do {
                try await supabaseService.registerDeviceToken(token: token, teamId: teamId)
                print("✅ Device token registered for team: \(teamId)")
            } catch {
                print("❌ Failed to register device token for team: \(error)")
            }
        }
    }

    // MARK: - Notification Handling

    /// Handle incoming remote notification
    func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        print("📬 Received remote notification")
        print("Notification data: \(userInfo)")

        // Parse notification type and data
        guard let notificationType = userInfo["type"] as? String else {
            print("⚠️ No notification type found")
            return
        }

        // Handle different notification types
        switch notificationType {
        case "announcement":
            handleAnnouncementNotification(userInfo)
        case "schedule":
            handleScheduleNotification(userInfo)
        case "schedule_change":
            handleScheduleChangeNotification(userInfo)
        case "game_reminder":
            handleGameReminderNotification(userInfo)
        case "practice_reminder":
            handlePracticeReminderNotification(userInfo)
        default:
            print("⚠️ Unknown notification type: \(notificationType)")
        }

        // Update badge count
        updateBadgeCount()
    }

    private func handleAnnouncementNotification(_ userInfo: [AnyHashable: Any]) {
        // Trigger data refresh for announcements
        NotificationCenter.default.post(
            name: NSNotification.Name("RefreshAnnouncements"),
            object: nil,
            userInfo: userInfo
        )
    }

    private func handleScheduleNotification(_ userInfo: [AnyHashable: Any]) {
        // Trigger data refresh for schedules
        NotificationCenter.default.post(
            name: NSNotification.Name("RefreshSchedules"),
            object: nil,
            userInfo: userInfo
        )
    }

    private func handleScheduleChangeNotification(_ userInfo: [AnyHashable: Any]) {
        // Trigger data refresh and show alert
        NotificationCenter.default.post(
            name: NSNotification.Name("ScheduleChanged"),
            object: nil,
            userInfo: userInfo
        )
    }

    private func handleGameReminderNotification(_ userInfo: [AnyHashable: Any]) {
        // Handle game reminder
        NotificationCenter.default.post(
            name: NSNotification.Name("GameReminder"),
            object: nil,
            userInfo: userInfo
        )
    }

    private func handlePracticeReminderNotification(_ userInfo: [AnyHashable: Any]) {
        // Handle practice reminder
        NotificationCenter.default.post(
            name: NSNotification.Name("PracticeReminder"),
            object: nil,
            userInfo: userInfo
        )
    }

    // MARK: - Badge Management

    /// Update app badge count based on unread notifications
    func updateBadgeCount() {
        Task { @MainActor in
            // This will be implemented to query SwiftData for unread announcements
            let unreadCount = 0 // TODO: Query SwiftData
            if #available(iOS 16.0, *) {
                UNUserNotificationCenter.current().setBadgeCount(unreadCount)
            } else {
                UIApplication.shared.applicationIconBadgeNumber = unreadCount
            }
        }
    }

    /// Clear badge count
    func clearBadgeCount() {
        Task { @MainActor in
            if #available(iOS 16.0, *) {
                UNUserNotificationCenter.current().setBadgeCount(0)
            } else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }

    // MARK: - Helper Methods

    /// Get current team ID from local storage
    private func getCurrentTeamId() -> UUID? {
        // This will query SwiftData for the current team
        // For now, return nil - will be implemented with SwiftData context
        return nil
    }

    /// Check if notifications are enabled for a specific category
    func isNotificationEnabled(for category: NotificationCategory) -> Bool {
        switch category {
        case .gameReminders:
            return UserDefaults.standard.bool(forKey: "gameReminders")
        case .practiceReminders:
            return UserDefaults.standard.bool(forKey: "practiceReminders")
        case .announcements:
            return UserDefaults.standard.bool(forKey: "announcementAlerts")
        case .scheduleChanges:
            return UserDefaults.standard.bool(forKey: "scheduleChangeAlerts")
        }
    }
}

// MARK: - Notification Categories

enum NotificationCategory: String, CaseIterable {
    case gameReminders = "Game Reminders"
    case practiceReminders = "Practice Reminders"
    case announcements = "Announcements"
    case scheduleChanges = "Schedule Changes"

    var userDefaultsKey: String {
        switch self {
        case .gameReminders: return "gameReminders"
        case .practiceReminders: return "practiceReminders"
        case .announcements: return "announcementAlerts"
        case .scheduleChanges: return "scheduleChangeAlerts"
        }
    }

    var icon: String {
        switch self {
        case .gameReminders: return "sportscourt.fill"
        case .practiceReminders: return "figure.basketball"
        case .announcements: return "megaphone.fill"
        case .scheduleChanges: return "calendar.badge.exclamationmark"
        }
    }
}
