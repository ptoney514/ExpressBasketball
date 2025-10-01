//
//  TeamCodeEntryView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI
import SwiftData

struct TeamCodeEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var teamCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingScanner = false
    @State private var showingPushPermission = false
    @Binding var hasJoinedTeam: Bool

    private let pushManager = PushNotificationManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Image(systemName: "basketball.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)

                VStack(spacing: 10) {
                    Text("Join Your Team")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Enter the 6-character team code provided by your coach")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 20) {
                    HStack {
                        TextField("TEAM CODE", text: $teamCode)
                            .textFieldStyle(.roundedBorder)
                            .textCase(.uppercase)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .onChange(of: teamCode) { _, newValue in
                                if newValue.count > 6 {
                                    teamCode = String(newValue.prefix(6))
                                }
                            }

                        Button(action: { showingScanner = true }) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button(action: joinTeam) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Join Team")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(teamCode.count == 6 ? Color.orange : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .disabled(teamCode.count != 6 || isLoading)
                    .padding(.horizontal)
                }

                Spacer()

                Button("Use Demo Team") {
                    loadDemoTeam()
                }
                .font(.footnote)
                .foregroundStyle(.blue)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingPushPermission) {
                PushNotificationPermissionView(
                    isPresented: $showingPushPermission,
                    onComplete: completeOnboarding
                )
            }
        }
    }

    private func joinTeam() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                if teamCode == "DEMO01" {
                    loadDemoTeam()
                } else {
                    errorMessage = "Invalid team code. Please try again."
                }
                isLoading = false
            }
        }
    }

    private func loadDemoTeam() {
        let demoTeam = Team(
            name: "Express United U14 Boys",
            ageGroup: "U14",
            season: "2024-2025",
            teamCode: "DEMO01",
            primaryColor: "#FF6B35",
            secondaryColor: "#2C3E50"
        )
        demoTeam.coachName = "Coach Johnson"
        demoTeam.assistantCoachName = "Coach Smith"

        modelContext.insert(demoTeam)

        createDemoPlayers(for: demoTeam)
        createDemoSchedule(for: demoTeam)
        createDemoAnnouncements(for: demoTeam)

        do {
            try modelContext.save()

            // Store team ID for push notification registration
            UserDefaults.standard.set(demoTeam.id.uuidString, forKey: "currentTeamId")

            // Show push notification permission prompt
            showingPushPermission = true
        } catch {
            errorMessage = "Failed to save team data"
        }
    }

    private func completeOnboarding() {
        // Register device token for the team if available
        if let teamIdString = UserDefaults.standard.string(forKey: "currentTeamId"),
           let teamId = UUID(uuidString: teamIdString) {
            pushManager.registerDeviceTokenForTeam(teamId: teamId)
        }

        hasJoinedTeam = true
    }

    private func createDemoPlayers(for team: Team) {
        let players = [
            ("Michael", "Johnson", "23", "Guard"),
            ("David", "Williams", "10", "Forward"),
            ("James", "Brown", "5", "Center"),
            ("Robert", "Davis", "12", "Guard"),
            ("William", "Miller", "15", "Forward"),
            ("Joseph", "Wilson", "21", "Guard"),
            ("Charles", "Moore", "33", "Center"),
            ("Thomas", "Taylor", "7", "Forward")
        ]

        for (first, last, number, position) in players {
            let player = Player(
                firstName: first,
                lastName: last,
                jerseyNumber: number,
                position: position
            )
            player.team = team
            team.players.append(player)
        }
    }

    private func createDemoSchedule(for team: Team) {
        let calendar = Calendar.current
        let today = Date()

        let events: [(EventType, Int, String, String?, Bool)] = [
            (.practice, 1, "Express Gym", nil, true),
            (.game, 3, "Home Court", "Lakers", true),
            (.practice, 4, "Express Gym", nil, true),
            (.game, 6, "Away Arena", "Warriors", false),
            (.tournament, 8, "Tournament Center", "Spring Classic", true),
            (.practice, 10, "Express Gym", nil, true),
            (.scrimmage, 12, "Home Court", "Practice Squad", true)
        ]

        for (type, daysFromNow, location, opponent, isHome) in events {
            if let date = calendar.date(byAdding: .day, value: daysFromNow, to: today) {
                let schedule = Schedule(
                    eventType: type,
                    location: location,
                    startTime: date,
                    opponent: opponent,
                    isHomeGame: isHome
                )
                schedule.team = team
                team.schedules.append(schedule)
            }
        }
    }

    private func createDemoAnnouncements(for team: Team) {
        let announcements = [
            (
                "Welcome to Express United!",
                "Parents and players, welcome to the 2024-2025 season! We're excited to have you as part of our Express family.",
                Priority.normal,
                Category.general
            ),
            (
                "Practice Schedule Change",
                "Tuesday's practice has been moved to 6:00 PM instead of 5:00 PM due to gym availability.",
                Priority.high,
                Category.practice
            ),
            (
                "Uniform Distribution",
                "Uniforms will be distributed after practice this Thursday. Please ensure all players attend.",
                Priority.normal,
                Category.uniform
            )
        ]

        for (title, message, priority, category) in announcements {
            let announcement = Announcement(
                title: title,
                message: message,
                priority: priority,
                category: category
            )
            announcement.team = team
            team.announcements.append(announcement)
        }
    }
}