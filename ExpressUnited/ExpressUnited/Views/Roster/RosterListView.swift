//
//  RosterListView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI
import SwiftData

struct RosterListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Player.jerseyNumber) private var players: [Player]

    private var activePlayers: [Player] {
        players.filter { $0.isActive }
    }

    private var groupedByPosition: [String: [Player]] {
        Dictionary(grouping: activePlayers) { $0.position }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedByPosition.keys.sorted(), id: \.self) { position in
                    Section(position + "s") {
                        ForEach(groupedByPosition[position] ?? []) { player in
                            NavigationLink(destination: PlayerDetailView(player: player)) {
                                PlayerRowView(player: player)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Roster")
            .cleanIOSHeader()
            .overlay {
                if players.isEmpty {
                    ContentUnavailableView(
                        "No Players",
                        systemImage: "person.3",
                        description: Text("Team roster will appear here")
                    )
                }
            }
        }
    }
}

struct PlayerRowView: View {
    let player: Player

    var body: some View {
        HStack {
            Text("#\(player.jerseyNumber)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.orange)
                .frame(width: 50, alignment: .leading)

            VStack(alignment: .leading) {
                Text(player.fullName)
                    .font(.headline)
                Text(player.position)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let height = player.height {
                Text(height)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}