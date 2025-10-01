//
//  AccountMenuView.swift
//  ExpressUnited
//
//  Created for Express Basketball - Account menu accessed via avatar button
//

import SwiftUI
import SwiftData

struct AccountMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var teams: [Team]

    @State private var showingSettings = false
    @State private var showingLeaveConfirmation = false

    var currentTeam: Team? {
        teams.first
    }

    var parentName: String {
        // TODO: Get from user profile
        "Mike Johnson"
    }

    var parentInitials: String {
        // TODO: Get from user profile
        "MJ"
    }

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .orange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(parentInitials)
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(parentName)
                                .font(.headline)
                                .foregroundColor(.primary)

                            if let team = currentTeam {
                                Text(team.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                // Main Actions
                Section {
                    Button(action: {
                        dismiss()
                        showingSettings = true
                    }) {
                        Label("Settings", systemImage: "gear")
                    }

                    NavigationLink(destination: NotificationPreferencesView()) {
                        Label("Notifications", systemImage: "bell")
                    }

                    NavigationLink(destination: MyProfileView()) {
                        Label("My Profile", systemImage: "person")
                    }
                } header: {
                    Text("Account")
                }

                // Team Actions
                if currentTeam != nil {
                    Section {
                        NavigationLink(destination: TeamInfoView()) {
                            Label("Team Info", systemImage: "info.circle")
                        }

                        NavigationLink(destination: TeamCodeShareView(team: currentTeam!)) {
                            Label("Share Team Code", systemImage: "qrcode")
                        }

                        // TODO: Add when multi-team support is ready
                        // Button(action: {}) {
                        //     Label("Switch Team", systemImage: "arrow.triangle.2.circlepath")
                        // }
                    } header: {
                        Text("Team")
                    }
                }

                // Support Section
                Section {
                    NavigationLink(destination: SupportView()) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }

                    NavigationLink(destination: PrivacyView()) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }

                    NavigationLink(destination: TermsView()) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }

                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.circle")
                    }
                } header: {
                    Text("Information")
                }

                // Danger Zone
                if currentTeam != nil {
                    Section {
                        Button(role: .destructive, action: {
                            showingLeaveConfirmation = true
                        }) {
                            Label("Leave Team", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Leave Team?", isPresented: $showingLeaveConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Leave Team", role: .destructive) {
                    leaveTeam()
                }
            } message: {
                Text("Are you sure you want to leave this team? You'll need the team code to rejoin.")
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private func leaveTeam() {
        if let team = currentTeam {
            modelContext.delete(team)
            do {
                try modelContext.save()
                dismiss()
            } catch {
                print("Error leaving team: \(error)")
            }
        }
    }
}

// MARK: - Supporting Views

struct MyProfileView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Name")
                    Spacer()
                    Text("Mike Johnson")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Email")
                    Spacer()
                    Text("mike@example.com")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Phone")
                    Spacer()
                    Text("(555) 123-4567")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Personal Information")
            } footer: {
                Text("Contact your team administrator to update your profile information.")
            }

            Section {
                Button("Edit Profile") {
                    // TODO: Implement profile editing
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TeamInfoView: View {
    @Query private var teams: [Team]

    var currentTeam: Team? {
        teams.first
    }

    var body: some View {
        Form {
            if let team = currentTeam {
                Section {
                    HStack {
                        Text("Team Name")
                        Spacer()
                        Text(team.name)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Age Group")
                        Spacer()
                        Text(team.ageGroup)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Season")
                        Spacer()
                        Text(team.season)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Team Code")
                        Spacer()
                        Text(team.teamCode)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text("Team Details")
                }

                Section {
                    if let coachName = team.coachName {
                        HStack {
                            Text("Head Coach")
                            Spacer()
                            Text(coachName)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let assistantCoach = team.assistantCoachName {
                        HStack {
                            Text("Assistant Coach")
                            Spacer()
                            Text(assistantCoach)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Coaching Staff")
                }

                Section {
                    HStack {
                        Text("Total Players")
                        Spacer()
                        Text("\(team.players.count)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Upcoming Events")
                        Spacer()
                        Text("\(team.schedules.filter { $0.startTime > Date() }.count)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Team Stats")
                }
            }
        }
        .navigationTitle("Team Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AccountMenuView()
        .modelContainer(for: [Team.self])
}
