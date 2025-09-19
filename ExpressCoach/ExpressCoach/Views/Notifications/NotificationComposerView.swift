//
//  NotificationComposerView.swift
//  ExpressCoach
//
//  Created on 9/19/25.
//

import SwiftUI
import SwiftData

struct NotificationComposerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var teams: [Team]

    @State private var selectedTemplate: NotificationTemplate = .custom
    @State private var selectedRecipient: RecipientType = .allPlayers
    @State private var selectedTeam: Team?
    @State private var selectedPlayers: Set<Player> = []
    @State private var customMessage = ""
    @State private var scheduleDate = Date()
    @State private var practiceLocation = ""
    @State private var isUrgent = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Team Selection") {
                    if teams.isEmpty {
                        Text("No teams available")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Select Team", selection: $selectedTeam) {
                            Text("Select Team").tag(nil as Team?)
                            ForEach(teams, id: \.id) { team in
                                Text(team.name).tag(team as Team?)
                            }
                        }
                    }
                }

                Section("Message Template") {
                    Picker("Template", selection: $selectedTemplate) {
                        ForEach(NotificationTemplate.allCases, id: \.self) { template in
                            Text(template.displayName).tag(template)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                if selectedTemplate != .custom {
                    Section("Template Details") {
                        switch selectedTemplate {
                        case .practiceReminder, .practiceChange:
                            DatePicker("Practice Date", selection: $scheduleDate, displayedComponents: [.date, .hourAndMinute])
                            TextField("Location", text: $practiceLocation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        case .gameUpdate:
                            DatePicker("Game Date", selection: $scheduleDate, displayedComponents: [.date, .hourAndMinute])
                            TextField("Location", text: $practiceLocation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        case .custom:
                            EmptyView()
                        }
                    }
                }

                Section("Message") {
                    if selectedTemplate == .custom {
                        TextField("Type your message...", text: $customMessage, axis: .vertical)
                            .lineLimit(5...10)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(generateTemplateMessage())
                            .padding()
                            .background(Color("BackgroundDark"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }

                Section("Recipients") {
                    Picker("Send to", selection: $selectedRecipient) {
                        ForEach(RecipientType.allCases, id: \.self) { recipient in
                            Text(recipient.displayName).tag(recipient)
                        }
                    }

                    if selectedRecipient == .specificPlayers {
                        if let team = selectedTeam, let players = team.players {
                            ForEach(players, id: \.id) { player in
                                HStack {
                                    Text("\(player.firstName) \(player.lastName)")
                                    Spacer()
                                    if selectedPlayers.contains(player) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color("BasketballOrange"))
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if selectedPlayers.contains(player) {
                                        selectedPlayers.remove(player)
                                    } else {
                                        selectedPlayers.insert(player)
                                    }
                                }
                            }
                        } else {
                            Text("Select a team first")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("Options") {
                    Toggle("Urgent Message", isOn: $isUrgent)
                        .toggleStyle(SwitchToggleStyle(tint: Color("BasketballOrange")))
                }
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
                    .disabled(!canSendNotification())
                    .foregroundColor(canSendNotification() ? Color("BasketballOrange") : .secondary)
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func generateTemplateMessage() -> String {
        let teamName = selectedTeam?.name ?? "Team"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        switch selectedTemplate {
        case .practiceReminder:
            return "🏀 Practice Reminder for \(teamName)\n\nDon't forget about practice on \(dateFormatter.string(from: scheduleDate))\nLocation: \(practiceLocation)\n\nSee you on the court!"

        case .practiceChange:
            return "⚠️ Practice Update for \(teamName)\n\nPractice has been rescheduled to \(dateFormatter.string(from: scheduleDate))\nNew Location: \(practiceLocation)\n\nPlease make note of the changes."

        case .gameUpdate:
            return "🏆 Game Update for \(teamName)\n\nUpcoming game: \(dateFormatter.string(from: scheduleDate))\nLocation: \(practiceLocation)\n\nLet's bring our A-game!"

        case .custom:
            return customMessage
        }
    }

    private func canSendNotification() -> Bool {
        guard selectedTeam != nil else { return false }

        switch selectedTemplate {
        case .custom:
            return !customMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .practiceReminder, .practiceChange, .gameUpdate:
            return !practiceLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private func sendNotification() {
        // TODO: Implement actual notification sending
        // For now, just dismiss the view
        print("Sending notification to \(selectedRecipient.displayName) for team \(selectedTeam?.name ?? "Unknown")")
        print("Message: \(generateTemplateMessage())")
        print("Urgent: \(isUrgent)")

        dismiss()
    }
}

enum NotificationTemplate: CaseIterable {
    case practiceReminder
    case practiceChange
    case gameUpdate
    case custom

    var displayName: String {
        switch self {
        case .practiceReminder: return "Practice Reminder"
        case .practiceChange: return "Practice Change"
        case .gameUpdate: return "Game Update"
        case .custom: return "Custom"
        }
    }
}

enum RecipientType: CaseIterable {
    case allPlayers
    case allParents
    case specificPlayers
    case assistantCoaches

    var displayName: String {
        switch self {
        case .allPlayers: return "All Players"
        case .allParents: return "All Parents"
        case .specificPlayers: return "Specific Players"
        case .assistantCoaches: return "Assistant Coaches"
        }
    }
}

#Preview {
    NotificationComposerView()
}