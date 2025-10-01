//
//  NotificationListView.swift
//  ExpressUnited
//
//  Created for Express Basketball - Notification center accessed via bell icon
//

import SwiftUI
import SwiftData

struct NotificationListView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var announcements: [Announcement]
    @Query private var schedules: [Schedule]

    @State private var selectedFilter: NotificationFilter = .all

    enum NotificationFilter: String, CaseIterable {
        case all = "All"
        case unread = "Unread"
        case urgent = "Urgent"
    }

    var notifications: [NotificationItem] {
        var items: [NotificationItem] = []

        // Add announcements as notifications
        for announcement in announcements {
            items.append(NotificationItem(
                id: announcement.id.uuidString,
                title: announcement.title,
                message: announcement.message,
                timestamp: announcement.createdAt,
                type: .announcement,
                priority: announcement.priority,
                isRead: announcement.isRead
            ))
        }

        // Add recent schedule updates (last 7 days)
        let recentSchedules = schedules.filter { schedule in
            let daysSinceUpdate = Calendar.current.dateComponents([.day], from: schedule.updatedAt, to: Date()).day ?? 0
            return daysSinceUpdate <= 7 && schedule.updatedAt != schedule.createdAt
        }

        for schedule in recentSchedules {
            items.append(NotificationItem(
                id: schedule.id.uuidString,
                title: "Schedule Update",
                message: "\(schedule.eventType.rawValue) time changed to \(schedule.startTime.formatted(date: .abbreviated, time: .shortened))",
                timestamp: schedule.updatedAt,
                type: .scheduleChange,
                priority: .high,
                isRead: true // Assuming schedule changes are auto-read
            ))
        }

        // Sort by timestamp (newest first)
        items.sort { $0.timestamp > $1.timestamp }

        // Apply filter
        switch selectedFilter {
        case .all:
            return items
        case .unread:
            return items.filter { !$0.isRead }
        case .urgent:
            return items.filter { $0.priority == .urgent }
        }
    }

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(NotificationFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue)
                            .tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if notifications.isEmpty {
                    EmptyNotificationsView(filter: selectedFilter)
                } else {
                    List {
                        ForEach(notifications) { notification in
                            NotificationRow(notification: notification)
                                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if unreadCount > 0 {
                        Text("\(unreadCount) unread")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Notification Item Model

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    let type: NotificationType
    let priority: Priority
    let isRead: Bool

    enum NotificationType {
        case announcement
        case scheduleChange
        case gameReminder
        case practiceReminder

        var icon: String {
            switch self {
            case .announcement:
                return "megaphone.fill"
            case .scheduleChange:
                return "calendar.badge.exclamationmark"
            case .gameReminder:
                return "sportscourt.fill"
            case .practiceReminder:
                return "figure.basketball"
            }
        }

        var color: Color {
            switch self {
            case .announcement:
                return .blue
            case .scheduleChange:
                return .orange
            case .gameReminder:
                return .purple
            case .practiceReminder:
                return .green
            }
        }
    }
}

// MARK: - Notification Row

struct NotificationRow: View {
    let notification: NotificationItem

    var timeAgo: String {
        let interval = Date().timeIntervalSince(notification.timestamp)
        let hours = Int(interval) / 3600

        if hours < 1 {
            let minutes = Int(interval) / 60
            return "\(minutes)m ago"
        } else if hours < 24 {
            return "\(hours)h ago"
        } else {
            let days = hours / 24
            return "\(days)d ago"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: notification.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(notification.type.color)
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    if notification.priority == .urgent {
                        Text("URGENT")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    if !notification.isRead {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }

                Text(notification.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text(timeAgo)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State

struct EmptyNotificationsView: View {
    let filter: NotificationListView.NotificationFilter

    var message: String {
        switch filter {
        case .all:
            return "No notifications yet"
        case .unread:
            return "You're all caught up!"
        case .urgent:
            return "No urgent notifications"
        }
    }

    var icon: String {
        switch filter {
        case .all:
            return "bell.slash"
        case .unread:
            return "checkmark.circle"
        case .urgent:
            return "exclamationmark.triangle"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)

            if filter == .all {
                Text("Notifications from your coach will appear here")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("With Notifications") {
    NotificationListView()
        .modelContainer(for: [Announcement.self, Schedule.self])
}

#Preview("Empty") {
    NotificationListView()
        .modelContainer(for: [Announcement.self, Schedule.self], inMemory: true)
}
