//
//  AppDelegate.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let pushManager = PushNotificationManager.shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set notification center delegate
        UNUserNotificationCenter.current().delegate = self

        // Configure notification categories
        configureNotificationCategories()

        print("✅ AppDelegate initialized")
        return true
    }

    // MARK: - Push Notification Registration

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        pushManager.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        pushManager.didFailToRegisterForRemoteNotifications(withError: error)
    }

    // MARK: - Remote Notification Handling

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📬 Received remote notification in background")
        pushManager.handleRemoteNotification(userInfo: userInfo)
        completionHandler(.newData)
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📬 Notification received while app in foreground")

        let userInfo = notification.request.content.userInfo
        pushManager.handleRemoteNotification(userInfo: userInfo)

        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    /// Handle notification tap/interaction
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("👆 User tapped on notification")

        let userInfo = response.notification.request.content.userInfo
        handleNotificationTap(userInfo: userInfo, actionIdentifier: response.actionIdentifier)

        completionHandler()
    }

    // MARK: - Notification Actions

    /// Configure notification categories with actions
    private func configureNotificationCategories() {
        // Announcement category
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ANNOUNCEMENT",
            title: "View",
            options: .foreground
        )
        let announcementCategory = UNNotificationCategory(
            identifier: "ANNOUNCEMENT",
            actions: [viewAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Schedule change category
        let viewScheduleAction = UNNotificationAction(
            identifier: "VIEW_SCHEDULE",
            title: "View Schedule",
            options: .foreground
        )
        let scheduleCategory = UNNotificationCategory(
            identifier: "SCHEDULE_CHANGE",
            actions: [viewScheduleAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Game reminder category
        let viewGameAction = UNNotificationAction(
            identifier: "VIEW_GAME",
            title: "View Details",
            options: .foreground
        )
        let gameCategory = UNNotificationCategory(
            identifier: "GAME_REMINDER",
            actions: [viewGameAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Practice reminder category
        let viewPracticeAction = UNNotificationAction(
            identifier: "VIEW_PRACTICE",
            title: "View Details",
            options: .foreground
        )
        let practiceCategory = UNNotificationCategory(
            identifier: "PRACTICE_REMINDER",
            actions: [viewPracticeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Register categories
        UNUserNotificationCenter.current().setNotificationCategories([
            announcementCategory,
            scheduleCategory,
            gameCategory,
            practiceCategory
        ])

        print("✅ Notification categories configured")
    }

    /// Handle notification tap and deep link to appropriate view
    private func handleNotificationTap(userInfo: [AnyHashable: Any], actionIdentifier: String) {
        guard let notificationType = userInfo["type"] as? String else {
            print("⚠️ No notification type found")
            return
        }

        // Post notification for deep linking
        var deepLinkInfo = userInfo
        deepLinkInfo["actionIdentifier"] = actionIdentifier

        switch notificationType {
        case "announcement":
            NotificationCenter.default.post(
                name: NSNotification.Name("DeepLinkToAnnouncement"),
                object: nil,
                userInfo: deepLinkInfo
            )

        case "schedule", "schedule_change", "game_reminder", "practice_reminder":
            NotificationCenter.default.post(
                name: NSNotification.Name("DeepLinkToSchedule"),
                object: nil,
                userInfo: deepLinkInfo
            )

        default:
            print("⚠️ Unknown notification type for deep link: \(notificationType)")
        }
    }
}
