//
//  RosterView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData

struct RosterView: View {
    @Query private var teams: [Team]
    @State private var searchText = ""
    @State private var showingAddPlayer = false
    @State private var selectedPlayer: Player?

    var currentTeam: Team? {
        teams.first
    }

    var filteredPlayers: [Player] {
        guard let players = currentTeam?.players else { return [] }

        if searchText.isEmpty {
            return players.sorted { $0.jerseyNumber < $1.jerseyNumber }
        } else {
            return players.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.jerseyNumber.contains(searchText)
            }.sorted { $0.jerseyNumber < $1.jerseyNumber }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if currentTeam == nil {
                    NoTeamView()
                } else if filteredPlayers.isEmpty && searchText.isEmpty {
                    EmptyRosterView(showingAddPlayer: $showingAddPlayer)
                } else {
                    PlayerListView(
                        players: filteredPlayers,
                        selectedPlayer: $selectedPlayer,
                        showingAddPlayer: $showingAddPlayer
                    )
                }
            }
            .navigationTitle("Roster")
            .searchable(text: $searchText, prompt: "Search players")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPlayer = true }) {
                        Image(systemName: "plus")
                    }
                    .disabled(currentTeam == nil)
                }
            }
            .sheet(isPresented: $showingAddPlayer) {
                if let team = currentTeam {
                    AddPlayerView(team: team)
                }
            }
            .sheet(item: $selectedPlayer) { player in
                PlayerDetailView(player: player)
            }
        }
    }
}

struct NoTeamView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3")
                .font(.system(size: 80))
                .foregroundColor(.secondary)

            Text("No Team Created")
                .font(.title)
                .bold()

            Text("Create a team first to manage your roster")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct EmptyRosterView: View {
    @Binding var showingAddPlayer: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.secondary)

            Text("No Players Yet")
                .font(.title)
                .bold()

            Text("Add players to build your roster")
                .foregroundColor(.secondary)

            Button(action: { showingAddPlayer = true }) {
                Label("Add First Player", systemImage: "plus.circle.fill")
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

struct PlayerListView: View {
    let players: [Player]
    @Binding var selectedPlayer: Player?
    @Binding var showingAddPlayer: Bool
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            ForEach(players) { player in
                PlayerRowView(player: player)
                    .onTapGesture {
                        selectedPlayer = player
                    }
            }
            .onDelete(perform: deletePlayer)
        }
    }

    private func deletePlayer(at offsets: IndexSet) {
        for index in offsets {
            let player = players[index]
            modelContext.delete(player)
        }

        do {
            try modelContext.save()
        } catch {
            print("Error deleting player: \(error)")
        }
    }
}

struct PlayerRowView: View {
    let player: Player

    var body: some View {
        HStack {
            Text(player.jerseyNumber)
                .font(.title2)
                .bold()
                .frame(width: 40)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(player.fullName)
                    .font(.headline)
                HStack {
                    Text(player.position)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("Grade \(player.grade)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}