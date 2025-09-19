//
//  Helpers.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import Foundation
import SwiftUI

struct TeamCodeGenerator {
    static func generate() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }

    static func validate(_ code: String) -> Bool {
        let pattern = "^[A-Z0-9]{6}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: code.utf16.count)
        return regex?.firstMatch(in: code, options: [], range: range) != nil
    }
}

struct DateHelper {
    static func upcomingGames(from schedules: [Schedule], limit: Int = 3) -> [Schedule] {
        schedules
            .filter { $0.eventType == .game && $0.startTime > Date() && !$0.isCancelled }
            .sorted { $0.startTime < $1.startTime }
            .prefix(limit)
            .map { $0 }
    }

    static func todaysEvents(from schedules: [Schedule]) -> [Schedule] {
        schedules.filter { $0.startTime.isToday() && !$0.isCancelled }
    }

    static func thisWeeksEvents(from schedules: [Schedule]) -> [Schedule] {
        schedules.filter { $0.startTime.isThisWeek() && !$0.isCancelled }
    }
}

struct TeamColors {
    static let defaultPrimary = Color(hex: "#FF6B35")
    static let defaultSecondary = Color(hex: "#2C3E50")

    static func primary(from hex: String?) -> Color {
        guard let hex = hex else { return defaultPrimary }
        return Color(hex: hex)
    }

    static func secondary(from hex: String?) -> Color {
        guard let hex = hex else { return defaultSecondary }
        return Color(hex: hex)
    }
}

struct EventFormatter {
    static func formatEventTime(_ schedule: Schedule) -> String {
        let formatter = DateFormatter()

        if schedule.startTime.isToday() {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if schedule.startTime.isTomorrow() {
            formatter.dateFormat = "'Tomorrow at' h:mm a"
        } else {
            formatter.dateFormat = "E, MMM d 'at' h:mm a"
        }

        return formatter.string(from: schedule.startTime)
    }

    static func formatEventDuration(_ schedule: Schedule) -> String {
        guard let endTime = schedule.endTime else { return "" }

        let duration = endTime.timeIntervalSince(schedule.startTime)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        } else {
            return "\(minutes) minutes"
        }
    }
}