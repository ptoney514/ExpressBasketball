import Foundation
import SwiftData

@Model
final class AIConversation: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var teamId: UUID
    var parentName: String
    var parentPhone: String?
    var subject: String
    var status: ConversationStatus
    var priority: Priority
    var category: QuestionCategory
    var createdAt: Date
    var updatedAt: Date
    var isRead: Bool
    var aiConfidence: Double

    @Relationship(deleteRule: .cascade) var messages: [AIMessage]?
    @Relationship var relatedSchedule: Schedule?
    @Relationship var relatedPlayer: Player?
    @Relationship var team: Team?

    init(
        teamId: UUID,
        parentName: String,
        subject: String,
        category: QuestionCategory = .general,
        priority: Priority = .normal
    ) {
        self.id = UUID()
        self.teamId = teamId
        self.parentName = parentName
        self.subject = subject
        self.status = .open
        self.priority = priority
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isRead = false
        self.aiConfidence = 0.0
    }

    enum ConversationStatus: String, Codable, CaseIterable, Sendable {
        case open = "Open"
        case inProgress = "In Progress"
        case resolved = "Resolved"
        case archived = "Archived"
    }

    enum Priority: String, Codable, CaseIterable, Sendable {
        case urgent = "Urgent"
        case high = "High"
        case normal = "Normal"
        case low = "Low"
    }
}

enum QuestionCategory: String, Codable, CaseIterable, Sendable {
    case schedule = "Schedule"
    case practiceTime = "Practice Time"
    case gameDetails = "Game Details"
    case uniform = "Uniform/Equipment"
    case travel = "Travel/Transportation"
    case registration = "Registration"
    case emergency = "Emergency"
    case general = "General"

    var icon: String {
        switch self {
        case .schedule, .practiceTime, .gameDetails:
            return "calendar"
        case .uniform:
            return "tshirt"
        case .travel:
            return "car"
        case .registration:
            return "doc.text"
        case .emergency:
            return "exclamationmark.triangle"
        case .general:
            return "questionmark.circle"
        }
    }

    var color: String {
        switch self {
        case .emergency:
            return "red"
        case .schedule, .practiceTime, .gameDetails:
            return "blue"
        case .uniform:
            return "purple"
        case .travel:
            return "green"
        case .registration:
            return "orange"
        case .general:
            return "gray"
        }
    }
}