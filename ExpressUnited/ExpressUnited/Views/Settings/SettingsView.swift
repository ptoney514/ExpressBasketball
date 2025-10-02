//
//  SettingsView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var teams: [Team]
    @State private var showingTeamCode = false
    @State private var showingAbout = false
    @State private var showingLeaveConfirmation = false
    @State private var showingNotificationPreferences = false
    @State private var showingEmailComingSoon = false
    @State private var showingSMSComingSoon = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("gameReminders") private var gameReminders = true
    @AppStorage("practiceReminders") private var practiceReminders = true
    @AppStorage("announcementAlerts") private var announcementAlerts = true

    var currentTeam: Team? {
        teams.first
    }

    var body: some View {
        NavigationStack {
            List {
                if let team = currentTeam {
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(team.name)
                                    .font(.headline)
                                Text("Team Code: \(team.teamCode)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button(action: { showingTeamCode = true }) {
                                Image(systemName: "qrcode")
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Current Team")
                    }
                }

                Section {
                    NavigationLink(destination: NotificationPreferencesView()) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundStyle(.orange)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Push Notifications")
                                    .font(.body)

                                Text(notificationsEnabled ? "Enabled" : "Disabled")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if notificationsEnabled {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }

                    Button(action: { showingEmailComingSoon = true }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.gray)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Email Notifications")
                                    .font(.body)
                                    .foregroundStyle(.primary)

                                Text("Coming Soon")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }

                            Spacer()

                            Image(systemName: "sparkles")
                                .foregroundStyle(.orange)
                        }
                    }

                    Button(action: { showingSMSComingSoon = true }) {
                        HStack {
                            Image(systemName: "message.fill")
                                .foregroundStyle(.gray)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("SMS Text Alerts")
                                    .font(.body)
                                    .foregroundStyle(.primary)

                                Text("Coming Soon")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }

                            Spacer()

                            Image(systemName: "sparkles")
                                .foregroundStyle(.orange)
                        }
                    }
                } header: {
                    Text("Communication Preferences")
                } footer: {
                    Text("Choose how you want to receive updates from your team. Push notifications are available now, with email and SMS coming soon!")
                }

                #if DEBUG
                Section {
                    NavigationLink(destination: NotificationTestView()) {
                        Label("Notification Testing", systemImage: "hammer.fill")
                            .foregroundStyle(.purple)
                    }
                } header: {
                    Text("Developer Tools")
                } footer: {
                    Text("Debug tools for testing notifications")
                }
                #endif

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

                    Button(action: { showingAbout = true }) {
                        Label("About", systemImage: "info.circle")
                    }
                } header: {
                    Text("Information")
                }

                if currentTeam != nil {
                    Section {
                        Button(action: { showingLeaveConfirmation = true }) {
                            Label("Leave Team", systemImage: "person.crop.circle.badge.minus")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingTeamCode) {
                if let team = currentTeam {
                    TeamCodeShareView(team: team)
                }
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert("Leave Team?", isPresented: $showingLeaveConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Leave Team", role: .destructive) {
                    leaveTeam()
                }
            } message: {
                Text("Are you sure you want to leave this team? You'll need the team code to rejoin.")
            }
            .sheet(isPresented: $showingEmailComingSoon) {
                ComingSoonFeatureView(feature: .emailNotifications)
            }
            .sheet(isPresented: $showingSMSComingSoon) {
                ComingSoonFeatureView(feature: .smsAlerts)
            }
        }
    }

    private func leaveTeam() {
        if let team = currentTeam {
            modelContext.delete(team)
            do {
                try modelContext.save()
            } catch {
                print("Error leaving team: \(error)")
            }
        }
    }
}

struct TeamCodeShareView: View {
    let team: Team
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Share Team Code")
                    .font(.title)
                    .fontWeight(.bold)

                Image(systemName: "qrcode")
                    .font(.system(size: 200))
                    .foregroundStyle(.secondary)

                Text(team.teamCode)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundStyle(.orange)

                Text("Share this code with other parents to join the team")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button(action: {
                    UIPasteboard.general.string = team.teamCode
                }) {
                    Label("Copy Code", systemImage: "doc.on.doc")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SupportView: View {
    var body: some View {
        Form {
            Section {
                Link(destination: URL(string: "mailto:support@expressbasketball.com")!) {
                    Label("Email Support", systemImage: "envelope")
                }
                Link(destination: URL(string: "https://expressbasketball.com/help")!) {
                    Label("Online Help Center", systemImage: "safari")
                }
            } header: {
                Text("Contact Support")
            }

            Section {
                Text("Express United App")
                Text("Version 1.0.0")
                    .foregroundStyle(.secondary)
            } header: {
                Text("App Information")
            }
        }
        .navigationTitle("Help & Support")
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy content would go here...")
                .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct TermsView: View {
    var body: some View {
        ScrollView {
            Text("Terms of Service content would go here...")
                .padding()
        }
        .navigationTitle("Terms of Service")
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "basketball.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)

                Text("Express United")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Version 1.0.0")
                    .foregroundStyle(.secondary)

                Text("The official app for Express United Basketball families")
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()

                Text("© 2025 Express United Basketball")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}