//
//  Announcement.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import Foundation
import SwiftData

@Model
final class Announcement {
    var id: UUID
    var title: String
    var message: String
    var priority: Priority
    var category: Category
    var isRead: Bool
    var expiresAt: Date?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(inverse: \Team.announcements)
    var team: Team?

    init(
        title: String,
        message: String,
        priority: Priority = .normal,
        category: Category = .general,
        expiresAt: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.message = message
        self.priority = priority
        self.category = category
        self.isRead = false
        self.expiresAt = expiresAt
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum Priority: String, Codable, CaseIterable {
    case urgent = "Urgent"
    case high = "High"
    case normal = "Normal"
    case low = "Low"

    var color: String {
        switch self {
        case .urgent: return "red"
        case .high: return "orange"
        case .normal: return "blue"
        case .low: return "gray"
        }
    }

    var icon: String {
        switch self {
        case .urgent: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.circle.fill"
        case .normal: return "info.circle.fill"
        case .low: return "circle.fill"
        }
    }
}

enum Category: String, Codable, CaseIterable {
    case general = "General"
    case schedule = "Schedule"
    case practice = "Practice"
    case game = "Game"
    case tournament = "Tournament"
    case uniform = "Uniform"
    case payment = "Payment"
    case travel = "Travel"
    case fundraising = "Fundraising"
    case social = "Social"

    var icon: String {
        switch self {
        case .general: return "megaphone"
        case .schedule: return "calendar"
        case .practice: return "figure.basketball"
        case .game: return "sportscourt"
        case .tournament: return "trophy"
        case .uniform: return "tshirt"
        case .payment: return "dollarsign.circle"
        case .travel: return "bus"
        case .fundraising: return "hands.sparkles"
        case .social: return "person.3"
        }
    }
}