//
//  NotificationService.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import Foundation
import UserNotifications
import Combine
import UIKit

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    @Published var isAuthorized = false

    private init() {
        checkAuthorizationStatus()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.registerForRemoteNotifications()
                }
            }
        }
    }

    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    private func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func scheduleGameReminder(for schedule: Schedule) {
        guard isAuthorized else { return }
        guard schedule.eventType == .game else { return }

        let content = UNMutableNotificationContent()
        content.title = "Game Reminder"
        content.body = "Game vs \(schedule.opponent ?? "TBD") starts in 2 hours at \(schedule.location)"
        content.sound = .default
        content.categoryIdentifier = "GAME_REMINDER"

        let reminderTime = schedule.startTime.addingTimeInterval(-7200)

        if reminderTime > Date() {
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: reminderTime
                ),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "game-\(schedule.id)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }

    func schedulePracticeReminder(for schedule: Schedule) {
        guard isAuthorized else { return }
        guard schedule.eventType == .practice else { return }

        let content = UNMutableNotificationContent()
        content.title = "Practice Reminder"
        content.body = "Practice starts in 1 hour at \(schedule.location)"
        content.sound = .default
        content.categoryIdentifier = "PRACTICE_REMINDER"

        let reminderTime = schedule.startTime.addingTimeInterval(-3600)

        if reminderTime > Date() {
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: reminderTime
                ),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "practice-\(schedule.id)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }

    func sendAnnouncementNotification(for announcement: Announcement) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = announcement.title
        content.body = announcement.message
        content.sound = announcement.priority == .urgent ? .defaultCritical : .default
        content.categoryIdentifier = "ANNOUNCEMENT"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "announcement-\(announcement.id)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }

    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}