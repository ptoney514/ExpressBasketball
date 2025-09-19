import Foundation
import SwiftData

@Model
final class AIMessage {
    @Attribute(.unique) var id: UUID
    var content: String
    var isFromParent: Bool
    var senderName: String
    var timestamp: Date
    var hasAISuggestion: Bool
    var aiSuggestedResponse: String?
    var wasAutoResponded: Bool
    var sentiment: Sentiment
    var coachApproved: Bool
    var coachEdited: Bool

    @Relationship(inverse: \AIConversation.messages) var conversation: AIConversation?

    init(
        content: String,
        isFromParent: Bool,
        senderName: String,
        sentiment: Sentiment = .neutral
    ) {
        self.id = UUID()
        self.content = content
        self.isFromParent = isFromParent
        self.senderName = senderName
        self.timestamp = Date()
        self.hasAISuggestion = false
        self.wasAutoResponded = false
        self.sentiment = sentiment
        self.coachApproved = false
        self.coachEdited = false
    }

    enum Sentiment: String, Codable, CaseIterable {
        case positive = "Positive"
        case neutral = "Neutral"
        case negative = "Negative"
        case urgent = "Urgent"
        case confused = "Confused"

        var icon: String {
            switch self {
            case .positive:
                return "face.smiling"
            case .neutral:
                return "face.neutral"
            case .negative:
                return "face.frowning"
            case .urgent:
                return "exclamationmark.bubble"
            case .confused:
                return "questionmark.bubble"
            }
        }

        var color: String {
            switch self {
            case .positive:
                return "green"
            case .neutral:
                return "gray"
            case .negative:
                return "orange"
            case .urgent:
                return "red"
            case .confused:
                return "blue"
            }
        }
    }
}