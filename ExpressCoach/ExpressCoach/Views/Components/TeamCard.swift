//
//  TeamCard.swift
//  ExpressCoach
//
//  Created on 9/19/25.
//

import SwiftUI
import SwiftData

struct TeamCard: View {
    let team: Team

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with team name and code
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(team.ageGroup)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("CODE")
                        .font(.caption2)
                        .foregroundColor(.gray)

                    Text(team.teamCode)
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(Color("BasketballOrange"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("CoachBlack"))
                        .cornerRadius(6)
                }
            }

            Divider()
                .background(.gray.opacity(0.3))

            // Team stats row
            HStack(spacing: 20) {
                StatColumn(title: "Players", value: "\(team.players?.count ?? 0)", color: Color("BasketballOrange"))
                StatColumn(title: "Record", value: team.seasonRecord ?? "0-0", color: Color("CourtGreen"))
                StatColumn(title: "Role", value: team.coachRole.displayName, color: .white)
            }

            // Coach and practice info
            if let practiceLocation = team.practiceLocation {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(Color("BasketballOrange"))
                        .font(.caption)
                    Text(practiceLocation)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            if let practiceTime = team.practiceTime {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(Color("BasketballOrange"))
                        .font(.caption)
                    Text(practiceTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(Color("BackgroundDark"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("BasketballOrange").opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct StatColumn: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    let sampleTeam = Team(
        name: "Lakers U14",
        ageGroup: "Under 14",
        coachName: "Coach Johnson",
        coachRole: .headCoach
    )
    sampleTeam.practiceLocation = "Gym A"
    sampleTeam.practiceTime = "Mon/Wed 6:00 PM"
    sampleTeam.seasonRecord = "8-2"

    return TeamCard(team: sampleTeam)
        .preferredColorScheme(.dark)
        .padding()
}