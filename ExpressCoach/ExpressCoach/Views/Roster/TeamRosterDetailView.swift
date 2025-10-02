//
//  TeamRosterDetailView.swift
//  ExpressCoach
//
//  Shows roster for a specific team
//

import SwiftUI
import SwiftData

struct TeamRosterDetailView: View {
    let team: Team
    @Environment(\.modelContext) private var modelContext
    @StateObject private var alertManager = AlertManager()
    @State private var searchText = ""
    @State private var showingAddPlayer = false
    @State private var selectedPlayer: Player?
    @State private var filteredPlayers: [Player] = []
    @State private var isLoading = false
    @State private var searchTask: Task<Void, Never>?
    @State private var showingBulkImport = false
    @State private var showingExportOptions = false
    @State private var csvExportData: Data?

    var sortedPlayers: [Player] {
        guard let players = team.players else { return [] }
        return players.sorted { player1, player2 in
            let num1 = Int(player1.jerseyNumber) ?? Int.max
            let num2 = Int(player2.jerseyNumber) ?? Int.max
            return num1 < num2
        }
    }

    private func updateFilteredPlayers() {
        searchTask?.cancel()

        searchTask = Task {
            // Add debounce for search performance
            try? await Task.sleep(nanoseconds: UInt64(AppConstants.Roster.searchDebounceDelay * 1_000_000_000))

            guard !Task.isCancelled else { return }

            await MainActor.run {
                if searchText.isEmpty {
                    filteredPlayers = sortedPlayers
                } else {
                    filteredPlayers = sortedPlayers.filter {
                        $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                        $0.jerseyNumber.contains(searchText)
                    }
                }
            }
        }
    }

    var body: some View {
        Group {
            if filteredPlayers.isEmpty && searchText.isEmpty {
                EmptyTeamRosterView(showingAddPlayer: $showingAddPlayer)
            } else if filteredPlayers.isEmpty && !searchText.isEmpty {
                RosterEmptyStateView.searchNoResults(searchTerm: searchText)
            } else {
                RosterPlayerListView(
                    players: filteredPlayers,
                    selectedPlayer: $selectedPlayer,
                    showingAddPlayer: $showingAddPlayer,
                    alertManager: alertManager
                )
            }
        }
        .loadingOverlay(isLoading: isLoading, message: "Loading roster...")
        .navigationTitle(team.name)
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search players")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        HapticManager.shared.lightImpact()
                        showingAddPlayer = true
                    } label: {
                        Label("Add Single Player", systemImage: "person.badge.plus")
                    }

                    Button {
                        HapticManager.shared.lightImpact()
                        showingBulkImport = true
                    } label: {
                        Label("Bulk Import", systemImage: "square.and.arrow.down")
                    }

                    Divider()

                    Button {
                        exportRosterToCSV()
                    } label: {
                        Label("Export to CSV", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("Roster options")
            }
        }
        .sheet(isPresented: $showingAddPlayer) {
            AddPlayerView(team: team)
        }
        .sheet(item: $selectedPlayer) { player in
            PlayerDetailView(player: player)
        }
        .sheet(isPresented: $showingBulkImport) {
            BulkImportView(team: team)
        }
        .sheet(isPresented: $showingExportOptions) {
            if let csvData = csvExportData,
               let url = saveCSVToTempFile(data: csvData) {
                ShareSheet(items: [url])
            }
        }
        .safeAreaInset(edge: .top) {
            TeamRosterHeader(team: team)
        }
        .onAppear {
            filteredPlayers = sortedPlayers
        }
        .onChange(of: searchText) { _, _ in
            updateFilteredPlayers()
        }
        .withAlertManager(alertManager)
    }

    // MARK: - CSV Export

    private func exportRosterToCSV() {
        let service = CSVImportService()
        let csvString = service.generateCSV(from: sortedPlayers)

        if let data = csvString.data(using: .utf8) {
            csvExportData = data
            showingExportOptions = true
        } else {
            alertManager.showError(
                NSError(domain: "CSVExport", code: 1),
                customMessage: "Failed to generate CSV file"
            )
        }
    }

    private func saveCSVToTempFile(data: Data) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(team.name.replacingOccurrences(of: " ", with: "_"))_roster.csv"
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            alertManager.showError(error, customMessage: "Failed to save CSV file")
            return nil
        }
    }
}

struct TeamRosterHeader: View {
    let team: Team

    var playerCount: Int {
        team.players?.count ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(team.ageGroup)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Age group: \(team.ageGroup)")

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

                    Spacer()

                    PlayerCountBadge(count: playerCount, style: .prominent)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .accessibilityElement(children: .combine)

            Divider()
        }
    }
}

struct EmptyTeamRosterView: View {
    @Binding var showingAddPlayer: Bool

    var body: some View {
        RosterEmptyStateView.noPlayers {
            HapticManager.shared.lightImpact()
            showingAddPlayer = true
        }
    }
}

struct RosterPlayerListView: View {
    let players: [Player]
    @Binding var selectedPlayer: Player?
    @Binding var showingAddPlayer: Bool
    let alertManager: AlertManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            ForEach(players) { player in
                RosterPlayerRowView(player: player)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        HapticManager.shared.selection()
                        selectedPlayer = player
                    }
                    .accessibilityHint(AppConstants.Accessibility.viewPlayerHint)
            }
            .onDelete(perform: confirmDelete)
        }
    }

    private func confirmDelete(at offsets: IndexSet) {
        guard let index = offsets.first,
              index < players.count else { return }

        let player = players[index]

        alertManager.showDeleteConfirmation(itemName: player.fullName) {
            deletePlayer(at: offsets)
        }
    }

    private func deletePlayer(at offsets: IndexSet) {
        for index in offsets {
            let player = players[index]
            modelContext.delete(player)
        }

        do {
            try modelContext.save()
            alertManager.showSuccess(
                title: "Player Removed",
                message: AppConstants.SuccessMessages.playerDeleted
            )
        } catch {
            modelContext.rollback()
            alertManager.showError(
                error,
                customMessage: AppConstants.ErrorMessages.deleteFailed,
                recovery: { deletePlayer(at: offsets) }
            )
        }
    }
}

struct RosterPlayerRowView: View {
    let player: Player

    var body: some View {
        HStack {
            Text(player.jerseyNumber)
                .font(.title2)
                .bold()
                .frame(width: 40)
                .foregroundColor(.blue)
                .accessibilityLabel("Jersey number \(player.jerseyNumber)")

            VStack(alignment: .leading, spacing: 4) {
                Text(player.fullName)
                    .font(.headline)
                    .accessibilityLabel("Player: \(player.fullName)")
                HStack {
                    Text(player.position)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                    Text("Class of \(String(player.graduationYear))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(player.position), Class of \(player.graduationYear)")
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(player.fullName), jersey \(player.jerseyNumber), \(player.position), class of \(player.graduationYear)")
        .accessibilityAddTraits(.isButton)
    }
}