import SwiftUI
import SwiftData

struct SendNotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var teams: [Team]
    @Query private var players: [Player]

    @State private var selectedTeam: Team?
    @State private var selectedTemplate = MessageTemplate.custom
    @State private var messageText = ""
    @State private var recipientType = RecipientType.allPlayers
    @State private var isUrgent = false
    @State private var showingPreview = false

    enum MessageTemplate: String, CaseIterable {
        case practiceReminder = "Practice Reminder"
        case practiceCancelled = "Practice Cancelled"
        case gameUpdate = "Game Update"
        case custom = "Custom"

        var defaultMessage: String {
            switch self {
            case .practiceReminder:
                return "Reminder: Practice today at [TIME] at [LOCATION]. Please arrive 10 minutes early for warm-ups. Bring water and appropriate gear."
            case .practiceCancelled:
                return "Today's practice has been cancelled due to [REASON]. We'll resume our regular schedule [NEXT DATE]. Stay ready!"
            case .gameUpdate:
                return "Game update: Our game against [OPPONENT] is at [TIME] at [LOCATION]. Arrive [ARRIVAL TIME] for warm-ups. Wear [UNIFORM COLOR] jerseys."
            case .custom:
                return ""
            }
        }
    }

    enum RecipientType: String, CaseIterable {
        case allPlayers = "All Players"
        case starters = "Starters Only"
        case bench = "Bench Players"
        case parents = "Parents Only"
        case everyone = "Everyone"

        var icon: String {
            switch self {
            case .allPlayers: return "person.3"
            case .starters: return "star"
            case .bench: return "person.2"
            case .parents: return "figure.2.and.child.holdinghands"
            case .everyone: return "person.3.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Team Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Team Selection", systemImage: "person.3.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Menu {
                            ForEach(teams) { team in
                                Button(action: { selectedTeam = team }) {
                                    HStack {
                                        Text(team.name)
                                        if !team.ageGroup.isEmpty {
                                            Text("(\(team.ageGroup))")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedTeam?.name ?? "Select Team")
                                    .foregroundColor(selectedTeam == nil ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }

                    // Message Template
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Message Template", systemImage: "text.bubble.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(MessageTemplate.allCases, id: \.self) { template in
                                    TemplateChip(
                                        title: template.rawValue,
                                        isSelected: selectedTemplate == template
                                    ) {
                                        selectedTemplate = template
                                        if template != .custom {
                                            messageText = template.defaultMessage
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Message
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Message", systemImage: "text.alignleft")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Spacer()

                            if !messageText.isEmpty {
                                Text("\(messageText.count) characters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        TextEditor(text: $messageText)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .overlay(
                                Group {
                                    if messageText.isEmpty {
                                        Text("Type your message...")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 16)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )

                        // AI Assist Button
                        Button(action: generateAIMessage) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Enhance with AI")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }

                    // Recipients
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Recipients", systemImage: "person.2.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Menu {
                            ForEach(RecipientType.allCases, id: \.self) { type in
                                Button(action: { recipientType = type }) {
                                    Label(type.rawValue, systemImage: type.icon)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: recipientType.icon)
                                    .foregroundColor(.blue)
                                Text(recipientType.rawValue)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }

                        if let team = selectedTeam {
                            RecipientPreview(
                                team: team,
                                recipientType: recipientType,
                                players: players.filter { $0.teams?.contains(team) ?? false }
                            )
                        }
                    }

                    // Options
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Options", systemImage: "gearshape.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Toggle(isOn: $isUrgent) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(isUrgent ? .red : .secondary)
                                Text("Urgent Message")
                                    .fontWeight(isUrgent ? .semibold : .regular)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                        if isUrgent {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("Urgent messages trigger immediate push notifications")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Send Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        sendNotification()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedTeam == nil || messageText.isEmpty)
                }
            }
        }
    }

    private func generateAIMessage() {
        // AI enhancement logic would go here
        if !messageText.isEmpty {
            messageText = "📢 " + messageText + "\n\n- Coach"
        }
    }

    private func sendNotification() {
        // Send notification logic
        dismiss()
    }
}

struct TemplateChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct RecipientPreview: View {
    let team: Team
    let recipientType: SendNotificationView.RecipientType
    let players: [Player]

    var recipientCount: Int {
        switch recipientType {
        case .allPlayers:
            return players.count
        case .starters:
            return min(5, players.count)
        case .bench:
            return max(0, players.count - 5)
        case .parents:
            return players.count
        case .everyone:
            return players.count * 2 // Players + Parents
        }
    }

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("\(recipientCount) recipients will receive this notification")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}