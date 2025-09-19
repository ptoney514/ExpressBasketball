//
//  AnnouncementsView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData

struct AnnouncementsView: View {
    @Query(sort: \Announcement.createdAt, order: .reverse) private var announcements: [Announcement]
    @Query private var teams: [Team]
    @State private var showingCreateAnnouncement = false

    var currentTeam: Team? {
        teams.first
    }

    var body: some View {
        NavigationStack {
            Group {
                if currentTeam == nil {
                    NoTeamAnnouncementsView()
                } else if announcements.isEmpty {
                    EmptyAnnouncementsView(showingCreateAnnouncement: $showingCreateAnnouncement)
                } else {
                    List(announcements) { announcement in
                        AnnouncementRowView(announcement: announcement)
                    }
                }
            }
            .navigationTitle("Announcements")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateAnnouncement = true }) {
                        Image(systemName: "plus")
                    }
                    .disabled(currentTeam == nil)
                }
            }
            .sheet(isPresented: $showingCreateAnnouncement) {
                if let team = currentTeam {
                    CreateAnnouncementView(team: team)
                }
            }
        }
    }
}

struct NoTeamAnnouncementsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "megaphone")
                .font(.system(size: 80))
                .foregroundColor(.secondary)

            Text("No Team Created")
                .font(.title)
                .bold()

            Text("Create a team first to send announcements")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct EmptyAnnouncementsView: View {
    @Binding var showingCreateAnnouncement: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "megaphone")
                .font(.system(size: 80))
                .foregroundColor(.secondary)

            Text("No Announcements")
                .font(.title)
                .bold()

            Text("Share important updates with your team")
                .foregroundColor(.secondary)

            Button(action: { showingCreateAnnouncement = true }) {
                Label("Create Announcement", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct AnnouncementRowView: View {
    let announcement: Announcement

    var priorityColor: Color {
        switch announcement.priority {
        case .urgent: return .red
        case .high: return .orange
        case .normal: return .blue
        case .low: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if announcement.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                Text(announcement.title)
                    .font(.headline)

                Spacer()

                Text(announcement.priority.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor)
                    .cornerRadius(6)
            }

            Text(announcement.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Text(announcement.createdAt, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct CreateAnnouncementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let team: Team

    @State private var title = ""
    @State private var content = ""
    @State private var priority: Announcement.Priority = .normal
    @State private var isPinned = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Announcement Details") {
                    TextField("Title", text: $title)

                    TextField("Message", text: $content, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section("Settings") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Announcement.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }

                    Toggle("Pin to Top", isOn: $isPinned)
                }
            }
            .navigationTitle("New Announcement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        createAnnouncement()
                    }
                    .bold()
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }

    private func createAnnouncement() {
        let announcement = Announcement(
            title: title,
            content: content,
            priority: priority,
            isPinned: isPinned
        )

        announcement.team = team
        modelContext.insert(announcement)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving announcement: \(error)")
        }
    }
}