import SwiftUI
import SwiftData

struct SuggestedResponsesView: View {
    let conversation: AIConversation
    let quickResponses: [QuickResponse]
    let onSelect: (String) -> Void
    @State private var aiSuggestions: [String] = []
    @State private var isGenerating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Suggested Responses", systemImage: "text.bubble.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Spacer()

                if isGenerating {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Button(action: generateAISuggestions) {
                        Label("Generate More", systemImage: "sparkles")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(aiSuggestions, id: \.self) { suggestion in
                        SuggestionChip(
                            text: suggestion,
                            icon: "sparkles",
                            color: .purple
                        ) {
                            onSelect(suggestion)
                        }
                    }

                    ForEach(quickResponses.prefix(3)) { response in
                        SuggestionChip(
                            text: response.title,
                            icon: "text.bubble",
                            color: Color("BasketballOrange")
                        ) {
                            onSelect(fillTemplate(response.template))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
        .onAppear {
            generateInitialSuggestions()
        }
    }

    private func generateInitialSuggestions() {
        aiSuggestions = generateContextualSuggestions()
    }

    private func generateAISuggestions() {
        isGenerating = true

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)

            await MainActor.run {
                aiSuggestions = generateContextualSuggestions()
                isGenerating = false
            }
        }
    }

    private func generateContextualSuggestions() -> [String] {
        switch conversation.category {
        case .practiceTime:
            return [
                "Practice is at 4:30 PM on Tuesday",
                "We practice twice a week",
                "Check the team calendar for times"
            ]
        case .gameDetails:
            return [
                "Game starts at 2 PM Saturday",
                "We're playing at home this week",
                "I'll send the full schedule tonight"
            ]
        case .uniform:
            return [
                "Wear white jerseys for home games",
                "Bring both jerseys to be safe",
                "Jersey color will be in the reminder"
            ]
        case .travel:
            return [
                "Meeting at 7 AM in the parking lot",
                "About 1.5 hour drive to the venue",
                "I'll share hotel details soon"
            ]
        case .emergency:
            return [
                "I'll call you right away",
                "Please seek medical attention",
                "Safety is our top priority"
            ]
        default:
            return [
                "I'll get back to you shortly",
                "Thanks for reaching out",
                "Let me check and confirm"
            ]
        }
    }

    private func fillTemplate(_ template: String) -> String {
        var filled = template
        let replacements = [
            "{time}": "4:30 PM",
            "{location}": "Community Center",
            "{arrival_time}": "30 minutes early",
            "{uniform_color}": "white",
            "{event_type}": "game",
            "{change_type}": "rescheduled",
            "{new_time}": "3:00 PM",
            "{date}": "March 15th",
            "{amount}": "$150",
            "{coach_phone}": "(555) 123-4567",
            "{duration}": "1.5 hours",
            "{address}": "123 Main St",
            "{departure_time}": "7:00 AM",
            "{meeting_spot}": "school parking lot"
        ]

        for (key, value) in replacements {
            filled = filled.replacingOccurrences(of: key, with: value)
        }

        return filled
    }
}

struct SuggestionChip: View {
    let text: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(text)
                    .lineLimit(1)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(16)
        }
    }
}