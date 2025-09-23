//
//  TeamDashboardView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData

struct TeamDashboardView: View {
    @Query private var teams: [Team]
    @State private var showingCreateTeam = false
    @State private var selectedTeam: Team?
    @State private var showingNotificationComposer = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()

                Group {
                    if teams.isEmpty {
                        EmptyTeamView(showingCreateTeam: $showingCreateTeam)
                    } else if let team = selectedTeam ?? teams.first {
                        TeamDetailDashboard(team: team, showingNotificationComposer: $showingNotificationComposer)
                    }
                }
            }
            .navigationTitle("Express Coach")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !teams.isEmpty {
                            Button(action: { showingNotificationComposer = true }) {
                                Image(systemName: "bell.badge")
                                    .foregroundColor(Color("BasketballOrange"))
                            }
                        }

                        Button(action: { showingCreateTeam = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(Color("BasketballOrange"))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateTeam) {
                CreateTeamView()
            }
            .sheet(isPresented: $showingNotificationComposer) {
                NotificationComposerView()
            }
        }
    }
}

struct EmptyTeamView: View {
    @Binding var showingCreateTeam: Bool

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color("BasketballOrange"))

                Text("Welcome to Express Coach")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Create your first team to start managing players, schedules, and communications")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: { showingCreateTeam = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Create Your First Team")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("BasketballOrange"))
                .cornerRadius(12)
            }
            .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Text("What you can do:")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                VStack(spacing: 8) {
                    FeatureRow(icon: "person.3.fill", text: "Manage your roster")
                    FeatureRow(icon: "calendar.circle.fill", text: "Schedule practices & games")
                    FeatureRow(icon: "bell.badge.fill", text: "Send instant notifications")
                    FeatureRow(icon: "sportscourt.fill", text: "Track game results")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundDark"))
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color("BasketballOrange"))
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

struct TeamDetailDashboard: View {
    let team: Team
    @Binding var showingNotificationComposer: Bool
    @Query private var upcomingSchedules: [Schedule]
    @State private var showingPracticeActions = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Team overview card
                TeamCard(team: team)
                    .id("team-card")

                // COMMUNICATION HUB - PRIMARY FOCUS
                // Recent Messages is the centerpiece of the dashboard
                RecentMessagesCard(team: team)
                    .id("recent-messages")
                    .shadow(color: Color("BasketballOrange").opacity(0.1), radius: 8, x: 0, y: 2)

                // This week's upcoming events
                ThisWeekEventsCard(schedules: upcomingSchedules)
                    .id("this-week")

                // Quick actions for coaches (secondary)
                CoachQuickActions(
                    team: team,
                    showingNotificationComposer: $showingNotificationComposer,
                    showingPracticeActions: $showingPracticeActions
                )
                .id("quick-actions")

                // Season overview stats
                QuickStatsCard(team: team)
                    .id("stats")
            }
            .padding()
        }
        .background(Color("BackgroundDark"))
        .actionSheet(isPresented: $showingPracticeActions) {
            ActionSheet(
                title: Text("Practice Actions"),
                message: Text("Quick actions for today's practice"),
                buttons: [
                    .default(Text("Send Practice Reminder")) {
                        showingNotificationComposer = true
                    },
                    .destructive(Text("Cancel Practice")) {
                        // TODO: Implement cancel practice
                    },
                    .default(Text("Update Location")) {
                        // TODO: Implement location update
                    },
                    .cancel()
                ]
            )
        }
    }
}

// Coach quick actions card
struct CoachQuickActions: View {
    let team: Team
    @Binding var showingNotificationComposer: Bool
    @Binding var showingPracticeActions: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.gray)
                    Text("Quick Actions")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(team.coachRole.displayName)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                CoachActionButton(
                    title: "Message Team",
                    icon: "message.fill",
                    color: Color("BasketballOrange"),
                    action: { showingNotificationComposer = true }
                )

                CoachActionButton(
                    title: "Send Alert",
                    icon: "bell.badge.fill",
                    color: Color.red,
                    action: { showingNotificationComposer = true }
                )

                CoachActionButton(
                    title: "Practice Update",
                    icon: "figure.basketball",
                    color: Color("CourtGreen"),
                    action: { showingPracticeActions = true }
                )

                CoachActionButton(
                    title: "Add Event",
                    icon: "calendar.badge.plus",
                    color: Color.purple,
                    action: {
                        // TODO: Navigate to add schedule
                    }
                )
            }
        }
        .padding()
        .background(Color("BackgroundDark"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct CoachActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(Color("CoachBlack"))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickStatsCard: View {
    let team: Team

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Season Overview")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text(team.seasonRecord ?? "0-0")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("CourtGreen"))
            }

            HStack(spacing: 20) {
                StatItem(title: "Games", value: "0", color: Color("BasketballOrange"))
                StatItem(title: "Wins", value: "0", color: Color("CourtGreen"))
                StatItem(title: "Practices", value: "0", color: Color.blue)
                StatItem(title: "Players", value: "\(team.players?.count ?? 0)", color: Color.purple)
            }
        }
        .padding()
        .background(Color("BackgroundDark"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ThisWeekEventsCard: View {
    let schedules: [Schedule]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(Color("BasketballOrange"))
                    Text("This Week")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Spacer()
                NavigationLink(destination: ScheduleView()) {
                    Text("Full Schedule")
                        .font(.caption)
                        .foregroundColor(Color("BasketballOrange"))
                }
            }

            if schedules.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.minus")
                        .font(.title2)
                        .foregroundColor(.gray)

                    Text("No events this week")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            } else {
                VStack(spacing: 8) {
                    ForEach(schedules.prefix(3)) { schedule in
                        CompactScheduleCard(schedule: schedule)
                    }
                }
            }
        }
        .padding()
        .background(Color("BackgroundDark"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

