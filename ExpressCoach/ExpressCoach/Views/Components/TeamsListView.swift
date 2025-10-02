//
//  TeamsListView.swift
//  ExpressCoach
//
//  Teams list component for dashboard
//

import SwiftUI
import SwiftData

struct TeamsListView: View {
    let teams: [Team]
    @Binding var selectedTeam: Team?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Text("My Teams")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Add team button
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color("BasketballOrange"))
                }
            }
            
            // Teams list
            VStack(spacing: 0) {
                ForEach(teams) { team in
                    TeamRowView(team: team, isSelected: selectedTeam?.id == team.id)
                        .onTapGesture {
                            selectedTeam = team
                        }
                    
                    if team != teams.last {
                        Divider()
                            .background(Color.gray.opacity(0.2))
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color("CoachBlack"))
            .cornerRadius(12)
        }
    }
}

struct TeamRowView: View {
    let team: Team
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Team info
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(team.ageGroup)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    // Coach info
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(team.coachName)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Record
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(team.seasonRecord ?? "0-0")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // Right side stats
            VStack(alignment: .trailing, spacing: 8) {
                // Player count
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(Color("BasketballOrange"))
                    Text("\(team.players?.count ?? 0)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("Players")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                // Selection indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(isSelected ? Color("BasketballOrange") : .gray.opacity(0.5))
            }
        }
        .padding()
        .background(
            isSelected ? Color("BasketballOrange").opacity(0.1) : Color.clear
        )
        .contentShape(Rectangle())
    }
}

#Preview {
    ZStack {
        Color("BackgroundDark")
            .ignoresSafeArea()
        
        TeamsListView(
            teams: {
                let team1 = Team(
                    name: "Express Lightning",
                    teamCode: "LIGHT01",
                    organization: "Express Basketball",
                    ageGroup: "U14 Boys",
                    season: "2024-25"
                )
                team1.coachName = "Mike Johnson"
                
                let team2 = Team(
                    name: "Express Thunder",
                    teamCode: "THUND01",
                    organization: "Express Basketball",
                    ageGroup: "U12 Boys",
                    season: "2024-25"
                )
                team2.coachName = "John Smith"
                
                return [team1, team2]
            }(),
            selectedTeam: .constant(nil)
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}