import Foundation
import SwiftData

@Model
final class QuickResponse {
    @Attribute(.unique) var id: UUID
    var title: String
    var template: String
    var category: QuestionCategory
    var keywords: [String]
    var usageCount: Int
    var lastUsed: Date?
    var isAIGenerated: Bool
    var isCustom: Bool
    var teamId: UUID?

    @Relationship var team: Team?

    init(
        title: String,
        template: String,
        category: QuestionCategory,
        keywords: [String] = [],
        isAIGenerated: Bool = false,
        isCustom: Bool = false,
        teamId: UUID? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.template = template
        self.category = category
        self.keywords = keywords
        self.usageCount = 0
        self.isAIGenerated = isAIGenerated
        self.isCustom = isCustom
        self.teamId = teamId
    }

    func incrementUsage() {
        self.usageCount += 1
        self.lastUsed = Date()
    }

    static var defaultTemplates: [QuickResponse] {
        [
            // Practice Templates
            QuickResponse(
                title: "Practice Reminder",
                template: "Reminder: Practice today at {time} at {location}. Please arrive 10 minutes early for warm-ups. Bring water and appropriate gear.",
                category: .practiceTime,
                keywords: ["practice", "reminder", "today", "time"]
            ),
            QuickResponse(
                title: "Practice Cancelled",
                template: "Today's practice has been cancelled due to {reason}. We'll resume our regular schedule {next_date}. Stay ready!",
                category: .practiceTime,
                keywords: ["practice", "cancelled", "cancel", "weather"]
            ),
            QuickResponse(
                title: "Practice Location Change",
                template: "Practice location changed: We'll be at {new_location} instead of our usual spot. Same time: {time}. See you there!",
                category: .practiceTime,
                keywords: ["practice", "location", "change", "moved"]
            ),

            // Game Templates
            QuickResponse(
                title: "Game Day Reminder",
                template: "Game Day! We play {opponent} at {time} at {location}. Arrive {arrival_time} for warm-ups. Wear {uniform_color} jerseys.",
                category: .gameDetails,
                keywords: ["game", "reminder", "today", "opponent"]
            ),
            QuickResponse(
                title: "Game Time Change",
                template: "Important: Our game against {opponent} has been moved to {new_time}. Location remains {location}. Please adjust your plans.",
                category: .gameDetails,
                keywords: ["game", "time", "change", "reschedule"]
            ),
            QuickResponse(
                title: "Post-Game Update",
                template: "Great game today! Final score: {score}. {highlight}. Our next game is {next_game_date}. Rest up!",
                category: .gameDetails,
                keywords: ["game", "score", "result", "win", "loss"]
            ),

            // Tournament Templates
            QuickResponse(
                title: "Tournament Schedule",
                template: "Tournament this weekend at {location}. First game: {time} on {day}. Full schedule in team app. Hotel info to follow.",
                category: .schedule,
                keywords: ["tournament", "weekend", "schedule", "games"]
            ),
            QuickResponse(
                title: "Tournament Packing List",
                template: "Tournament packing reminder: Both jerseys, extra socks, snacks, water bottles, any medications. Weather expected: {weather}.",
                category: .uniform,
                keywords: ["tournament", "pack", "bring", "uniforms"]
            ),

            // Travel Templates
            QuickResponse(
                title: "Departure Time",
                template: "Bus/Carpool leaves at {departure_time} from {meeting_location}. Game is at {game_time}. Don't be late!",
                category: .travel,
                keywords: ["leave", "departure", "bus", "carpool"]
            ),
            QuickResponse(
                title: "Hotel Information",
                template: "Team hotel: {hotel_name}, {address}. Check-in after {time}. Team dinner at {dinner_time} in {location}.",
                category: .travel,
                keywords: ["hotel", "stay", "room", "accommodation"]
            ),

            // Uniform Templates
            QuickResponse(
                title: "Jersey Day",
                template: "Tomorrow is {jersey_color} jersey day. {event_type} at {time}. Matching shorts and team socks required.",
                category: .uniform,
                keywords: ["jersey", "uniform", "wear", "color"]
            ),
            QuickResponse(
                title: "Spirit Wear",
                template: "Spirit wear day {day}! Players can wear team hoodies/shirts to school. Show your team pride!",
                category: .uniform,
                keywords: ["spirit", "wear", "school", "pride"]
            ),

            // Weather Templates
            QuickResponse(
                title: "Weather Update",
                template: "Weather update for {event}: {conditions}. {recommendation}. Event is {status}. Check app for updates.",
                category: .schedule,
                keywords: ["weather", "rain", "cold", "hot", "conditions"]
            ),
            QuickResponse(
                title: "Indoor/Outdoor Change",
                template: "Due to weather, {event} has been moved {indoor_outdoor}. New location: {location}. Time remains {time}.",
                category: .schedule,
                keywords: ["weather", "indoor", "outdoor", "moved"]
            ),

            // Registration/Payment Templates
            QuickResponse(
                title: "Payment Reminder",
                template: "Reminder: {payment_type} payment of ${amount} is due {date}. Pay via {method}. Contact me with questions.",
                category: .registration,
                keywords: ["payment", "fee", "due", "pay", "money"]
            ),
            QuickResponse(
                title: "Registration Deadline",
                template: "Last call! Registration for {event} closes {date}. Cost: ${amount}. Register at {link_or_location}.",
                category: .registration,
                keywords: ["register", "deadline", "signup", "tournament"]
            ),

            // Emergency Templates
            QuickResponse(
                title: "Injury Update",
                template: "Update on {player_name}: {status}. Expected return: {timeline}. Thanks for your patience and support.",
                category: .emergency,
                keywords: ["injury", "hurt", "update", "status"]
            ),
            QuickResponse(
                title: "Emergency Contact",
                template: "For emergencies, call me at {coach_phone}. For urgent game-day issues, text is preferred. Safety is our priority.",
                category: .emergency,
                keywords: ["emergency", "urgent", "call", "contact"]
            ),

            // General Templates
            QuickResponse(
                title: "Quick Acknowledgment",
                template: "Got it, thanks! I'll follow up with more details soon.",
                category: .general,
                keywords: ["thanks", "ok", "received", "got"]
            ),
            QuickResponse(
                title: "Parent Volunteer Request",
                template: "We need {number} parent volunteers for {event} on {date}. Tasks include: {tasks}. Please let me know if you can help!",
                category: .general,
                keywords: ["volunteer", "help", "parent", "need"]
            ),
            QuickResponse(
                title: "Team Celebration",
                template: "Celebrate! {achievement}! So proud of this team. {celebration_plan}. More details coming.",
                category: .general,
                keywords: ["celebrate", "win", "achievement", "proud"]
            )
        ]
    }
}