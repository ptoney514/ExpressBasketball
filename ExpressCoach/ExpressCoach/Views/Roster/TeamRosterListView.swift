//
//  TeamRosterListView.swift
//  ExpressCoach
//
//  Shows list of teams for roster management
//

import SwiftUI
import SwiftData

struct TeamRosterListView: View {
    @Query private var teams: [Team]
    @State private var selectedTeam: Team?

    var body: some View {
        NavigationStack {
            Group {
                if teams.isEmpty {
                    NoTeamsView()
                } else {
                    TeamListView(teams: teams, selectedTeam: $selectedTeam)
                }
            }
            .navigationTitle("Teams")
            .navigationDestination(item: $selectedTeam) { team in
                TeamRosterDetailView(team: team)
            }
        }
    }
}

struct NoTeamsView: View {
    var body: some View {
        RosterEmptyStateView.noTeams {
            // Team creation would be handled here
            // For now, this is a placeholder
            print("Create team tapped")
        }
    }
}

struct TeamListView: View {
    let teams: [Team]
    @Binding var selectedTeam: Team?

    var body: some View {
        List {
            ForEach(teams) { team in
                TeamRosterCard(team: team)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        HapticManager.shared.selection()
                        withAnimation(.easeInOut(duration: AppConstants.UI.quickAnimationDuration)) {
                            selectedTeam = team
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct TeamRosterCard: View {
    let team: Team

    var playerCount: Int {
        team.players?.count ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.headline)
                        .accessibilityLabel("Team: \(team.name)")

                    Text(team.ageGroup)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Age group: \(team.ageGroup)")
                }

                Spacer()

                PlayerCountBadge(count: playerCount, style: .standard)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }

            HStack(spacing: 12) {
                Label(team.coachName, systemImage: "person.badge.shield.checkmark")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Coach: \(team.coachName)")

                if let record = team.seasonRecord, !record.isEmpty {
                    Label(record, systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Season record: \(record)")
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(team.name), \(team.ageGroup), \(playerCount) players, coached by \(team.coachName)" + (team.seasonRecord != nil ? ", season record \(team.seasonRecord!)" : ""))
        .accessibilityHint(AppConstants.Accessibility.selectTeamHint)
        .accessibilityAddTraits(.isButton)
    }
}