//
//  HomeView.swift
//  ExpressCoach
//
//  Created on 9/21/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var teams: [Team]
    @Query private var schedules: [Schedule]
    @Query private var announcements: [Announcement]
    @State private var showingNotificationComposer = false
    @State private var showingAIChat = false
    @State private var selectedAIAction: AIQuickAction?
    @State private var showingAIAssistantCoach = false
    @State private var showingAddSchedule = false
    @State private var showingTeamCode = false

    var currentTeam: Team? {
        teams.first
    }

    var upcomingEvents: [Schedule] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekFromNow = calendar.date(byAdding: .day, value: 7, to: today) ?? Date()

        return schedules
            .filter { $0.date >= today && $0.date <= weekFromNow }
            .sorted { $0.date < $1.date }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    welcomeSection

                    // AI Quick Actions integrated seamlessly (Team Code button added here)
                    aiQuickActionsSection

                    // Team Overview Stats - Removed per user request
                    // Club basketball doesn't track wins/losses in this way
                    // if currentTeam != nil {
                    //     teamOverviewSection
                    // }

                    // Recent Messages - Primary communication focus (moved above This Week)
                    RecentMessagesCard(team: currentTeam ?? {
                        let defaultTeam = Team(
                            name: "Express Lightning",
                            teamCode: "LIGHT01",
                            organization: "Express Basketball",
                            ageGroup: "U14",
                            season: "2024-25"
                        )
                        defaultTeam.coachName = "Coach"
                        return defaultTeam
                    }())

                    // This Week's Events
                    if !upcomingEvents.isEmpty {
                        upcomingEventsSection
                    }
                }
                .padding()
            }
            .background(Color("BackgroundDark"))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNotificationComposer = true }) {
                        Image(systemName: "bell.badge")
                            .foregroundColor(Color("BasketballOrange"))
                    }
                }
            }
            .sheet(isPresented: $showingNotificationComposer) {
                NotificationComposerView()
            }
            .sheet(isPresented: $showingAIChat) {
                AIConversationView()
            }
            .sheet(isPresented: $showingAIAssistantCoach) {
                AIAssistantView()
            }
            .sheet(isPresented: $showingAddSchedule) {
                if let team = currentTeam {
                    AddScheduleView(team: team)
                }
            }
            .sheet(isPresented: $showingTeamCode) {
                if let team = currentTeam {
                    TeamCodeDetailView(team: team)
                }
            }
        }
    }

    // MARK: - View Sections

    private var welcomeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back, Coach")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if let team = currentTeam {
                    Text(team.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // AI Assistant indicator - subtle but present
            Button(action: { showingAIChat = true }) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 44, height: 44)

                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var aiQuickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Coach Actions")
                .font(.headline)
                .foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                // Notify Team (top-left)
                HomeCoachActionButton(
                    icon: "bell.fill",
                    title: "Notify Team",
                    color: Color("BasketballOrange")
                ) {
                    showingNotificationComposer = true
                }

                // Team Code (top-right)
                HomeCoachActionButton(
                    icon: "qrcode",
                    title: "Team Code",
                    color: .green
                ) {
                    showingTeamCode = true
                }

                // AI Assistant Coach (bottom-left)
                HomeCoachActionButton(
                    icon: "sparkles",
                    title: "AI Assistant Coach",
                    color: .blue
                ) {
                    // Navigate to AI Assistant Coach view
                    showingAIAssistantCoach = true
                }

                // Update Schedule (bottom-right)
                HomeCoachActionButton(
                    icon: "calendar.badge.plus",
                    title: "Update Schedule",
                    color: .purple
                ) {
                    // Navigate to add schedule
                    showingAddSchedule = true
                }
            }
        }
    }

    private var teamOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team Overview")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 12) {
                HomeStatCard(
                    value: "\(currentTeam?.players?.count ?? 0)",
                    label: "Players",
                    icon: "person.3.fill",
                    color: Color("BasketballOrange")
                )

                HomeStatCard(
                    value: "\(schedules.count)",
                    label: "Events",
                    icon: "calendar",
                    color: .green
                )

                HomeStatCard(
                    value: "\(upcomingEvents.count)",
                    label: "This Week",
                    icon: "clock.fill",
                    color: .blue
                )

                HomeStatCard(
                    value: "12-3",
                    label: "Record",
                    icon: "trophy.fill",
                    color: .yellow
                )
            }
        }
    }

    private var upcomingEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                NavigationLink(destination: ScheduleView()) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(Color("BasketballOrange"))
                }
            }

            ForEach(upcomingEvents.prefix(3)) { event in
                CompactEventCard(event: event)
            }
        }
    }

}

// MARK: - Supporting Views

struct HomeCoachActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color("CoachBlack"))
            .cornerRadius(12)
        }
    }
}

struct HomeStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color("CoachBlack"))
        .cornerRadius(12)
    }
}

struct CompactEventCard: View {
    let event: Schedule

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: "calendar")
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(event.eventType.rawValue)\(event.opponent != nil ? " vs \(event.opponent!)" : "")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    Label(event.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Label(event.location, systemImage: "location")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color("CoachBlack"))
        .cornerRadius(12)
    }
}

// MARK: - AI Action Types

enum AIQuickAction {
    case practicePlan
    case insights
    case draftMessage
}

// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(for: [Team.self, Player.self, Schedule.self])
}