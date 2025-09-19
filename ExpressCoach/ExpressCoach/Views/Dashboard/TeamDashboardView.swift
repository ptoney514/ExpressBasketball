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

    var body: some View {
        NavigationStack {
            Group {
                if teams.isEmpty {
                    EmptyTeamView(showingCreateTeam: $showingCreateTeam)
                } else if let team = selectedTeam ?? teams.first {
                    TeamDetailDashboard(team: team)
                }
            }
            .navigationTitle("Express Coach")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateTeam = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateTeam) {
                CreateTeamView()
            }
        }
    }
}

struct EmptyTeamView: View {
    @Binding var showingCreateTeam: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sportscourt")
                .font(.system(size: 80))
                .foregroundColor(.secondary)

            Text("No Teams Yet")
                .font(.title)
                .bold()

            Text("Create your first team to get started")
                .foregroundColor(.secondary)

            Button(action: { showingCreateTeam = true }) {
                Label("Create Team", systemImage: "plus.circle.fill")
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

struct TeamDetailDashboard: View {
    let team: Team
    @Query private var upcomingSchedules: [Schedule]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TeamHeaderCard(team: team)

                QuickStatsCard(team: team)

                UpcomingEventsCard(schedules: upcomingSchedules)

                QuickActionsCard()
            }
            .padding()
        }
    }
}

struct TeamHeaderCard: View {
    let team: Team

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(team.name)
                        .font(.title)
                        .bold()
                    Text(team.ageGroup)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Team Code")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(team.teamCode)
                        .font(.headline)
                        .monospaced()
                }
            }

            Divider()

            HStack {
                Label(team.coachName, systemImage: "person.fill")
                    .font(.subheadline)
                Spacer()
                if let playerCount = team.players?.count {
                    Label("\(playerCount) Players", systemImage: "person.3.fill")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickStatsCard: View {
    let team: Team

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Season Overview")
                .font(.headline)

            HStack(spacing: 20) {
                StatItem(title: "Games", value: "0", color: .blue)
                StatItem(title: "Wins", value: "0", color: .green)
                StatItem(title: "Practices", value: "0", color: .orange)
                StatItem(title: "Players", value: "\(team.players?.count ?? 0)", color: .purple)
            }
        }
        .padding()
        .background(Color(.systemGray6))
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
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct UpcomingEventsCard: View {
    let schedules: [Schedule]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Upcoming")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: ScheduleView()) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            if schedules.isEmpty {
                Text("No upcoming events")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                ForEach(schedules.prefix(3)) { schedule in
                    HStack {
                        Image(systemName: schedule.eventType == .game ? "sportscourt" : "figure.basketball")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(schedule.eventType.rawValue)
                                .font(.subheadline)
                                .bold()
                            Text(schedule.location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(schedule.date, style: .date)
                            .font(.caption)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickActionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 15) {
                QuickActionButton(title: "Add Player", icon: "person.badge.plus", color: .blue)
                QuickActionButton(title: "Schedule", icon: "calendar.badge.plus", color: .green)
                QuickActionButton(title: "Announce", icon: "megaphone", color: .orange)
                QuickActionButton(title: "Share Code", icon: "qrcode", color: .purple)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}