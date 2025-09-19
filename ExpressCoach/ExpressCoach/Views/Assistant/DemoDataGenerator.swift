import Foundation
import SwiftData

struct DemoDataGenerator {
    static func createDemoConversations(in modelContext: ModelContext) {
        let demoConversations = [
            (
                parent: "Sarah Johnson",
                subject: "Practice time this week?",
                category: QuestionCategory.practiceTime,
                priority: AIConversation.Priority.normal,
                aiConfidence: 0.95,
                messages: [
                    ("Hi Coach! What time is practice this Tuesday?", true, "Sarah Johnson"),
                    ("Practice is at 4:30 PM at the Community Center gym. Please arrive 10 minutes early for warm-ups!", false, "Coach"),
                    ("Perfect, thank you!", true, "Sarah Johnson")
                ]
            ),
            (
                parent: "Mike Chen",
                subject: "Saturday's game details",
                category: QuestionCategory.gameDetails,
                priority: AIConversation.Priority.high,
                aiConfidence: 0.88,
                messages: [
                    ("Can you send me the details for Saturday's game? I need to arrange transportation.", true, "Mike Chen"),
                    ("Game is at 2:00 PM at Lincoln High School. Please arrive by 1:15 PM for warm-up. We'll be wearing white jerseys.", false, "Coach"),
                    ("Should we bring both jerseys just in case?", true, "Mike Chen"),
                    ("Yes, always bring both jerseys to games. Thanks for checking!", false, "Coach")
                ]
            ),
            (
                parent: "Lisa Thompson",
                subject: "URGENT: Player injury",
                category: QuestionCategory.emergency,
                priority: AIConversation.Priority.urgent,
                aiConfidence: 0.3,
                messages: [
                    ("Coach, Emma twisted her ankle at practice. She's in pain but can walk. Should we go to urgent care?", true, "Lisa Thompson")
                ]
            ),
            (
                parent: "David Martinez",
                subject: "Tournament travel info",
                category: QuestionCategory.travel,
                priority: AIConversation.Priority.normal,
                aiConfidence: 0.82,
                messages: [
                    ("What are the travel plans for next month's tournament?", true, "David Martinez")
                ]
            ),
            (
                parent: "Jennifer Williams",
                subject: "Uniform question",
                category: QuestionCategory.uniform,
                priority: AIConversation.Priority.low,
                aiConfidence: 0.92,
                messages: [
                    ("My son's jersey is getting small. How do we order a new one?", true, "Jennifer Williams"),
                    ("You can order new jerseys through our team store. I'll send you the link. What size does he need?", false, "Coach"),
                    ("He needs a Youth Large now. Thanks!", true, "Jennifer Williams")
                ]
            ),
            (
                parent: "Robert Brown",
                subject: "Registration for spring season",
                category: QuestionCategory.registration,
                priority: AIConversation.Priority.normal,
                aiConfidence: 0.75,
                messages: [
                    ("When does registration open for the spring season?", true, "Robert Brown")
                ]
            )
        ]

        for (index, data) in demoConversations.enumerated() {
            let conversation = AIConversation(
                teamId: UUID(),
                parentName: data.parent,
                subject: data.subject,
                category: data.category,
                priority: data.priority
            )

            conversation.aiConfidence = data.aiConfidence
            conversation.isRead = index > 1
            conversation.status = index < 2 ? .resolved : (index == 2 ? .open : .inProgress)
            conversation.createdAt = Date().addingTimeInterval(TimeInterval(-86400 * (5 - index)))
            conversation.updatedAt = Date().addingTimeInterval(TimeInterval(-3600 * (10 - index)))

            var messages: [AIMessage] = []
            for (messageIndex, messageData) in data.messages.enumerated() {
                let message = AIMessage(
                    content: messageData.0,
                    isFromParent: messageData.1,
                    senderName: messageData.2,
                    sentiment: data.priority == .urgent ? .urgent : .neutral
                )

                message.timestamp = Date().addingTimeInterval(TimeInterval(-3600 * (10 - index) + (300 * messageIndex)))

                if !message.isFromParent && messageIndex == 1 {
                    message.hasAISuggestion = true
                    message.aiSuggestedResponse = messageData.0
                }

                messages.append(message)
            }

            conversation.messages = messages
            modelContext.insert(conversation)
        }

        for template in QuickResponse.defaultTemplates {
            modelContext.insert(template)
        }

        try? modelContext.save()
    }

    static func createDemoTeamIfNeeded(in modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Team>()
        let teams = try? modelContext.fetch(fetchDescriptor)

        if teams?.isEmpty ?? true {
            let team = Team(
                name: "Express Elite U14",
                ageGroup: "U14",
                coachName: "Coach Johnson"
            )
            team.teamCode = "EXP123"
            modelContext.insert(team)
            try? modelContext.save()
        }
    }
}