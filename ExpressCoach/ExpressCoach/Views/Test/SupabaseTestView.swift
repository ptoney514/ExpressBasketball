import SwiftUI
import Supabase

struct SupabaseTestView: View {
    @State private var teams: [TeamData] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTeam: TeamData?

    private let supabase = SupabaseConfig.client

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView("Loading teams...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("BasketballOrange")))
                        .foregroundColor(.white)
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)

                        Text("Error")
                            .font(.title)
                            .foregroundColor(.white)

                        Text(error)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Retry") {
                            Task { await loadTeams() }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("BasketballOrange"))
                        .cornerRadius(10)
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Supabase Connection Test")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            Text("Teams from Database (\(teams.count))")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)

                            ForEach(teams) { team in
                                SupabaseTeamRowView(team: team, isSelected: selectedTeam?.id == team.id)
                                    .onTapGesture {
                                        selectedTeam = team
                                        Task { await loadTeamDetails(team) }
                                    }
                            }

                            if let selected = selectedTeam {
                                TeamDetailsSection(team: selected)
                                    .padding(.top)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                await loadTeams()
            }
        }
    }

    func loadTeams() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await supabase
                .from("teams")
                .select()
                .execute()

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            teams = try decoder.decode([TeamData].self, from: response.data)

            print("Successfully loaded \(teams.count) teams")
        } catch {
            errorMessage = "Failed to load teams: \(error.localizedDescription)"
            print("Error loading teams: \(error)")
        }

        isLoading = false
    }

    func loadTeamDetails(_ team: TeamData) async {
        do {
            // Load players
            let playersResponse = try await supabase
                .from("players")
                .select()
                .eq("team_id", value: team.id.uuidString)
                .execute()

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let players = try decoder.decode([PlayerData].self, from: playersResponse.data)

            print("Loaded \(players.count) players for team \(team.name)")

            // Load schedules
            let schedulesResponse = try await supabase
                .from("schedules")
                .select()
                .eq("team_id", value: team.id.uuidString)
                .execute()

            decoder.dateDecodingStrategy = .iso8601
            let schedules = try decoder.decode([ScheduleData].self, from: schedulesResponse.data)

            print("Loaded \(schedules.count) schedules for team \(team.name)")

        } catch {
            print("Error loading team details: \(error)")
        }
    }
}

struct SupabaseTeamRowView: View {
    let team: TeamData
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    Label(team.teamCode, systemImage: "qrcode")
                        .font(.caption)
                        .foregroundColor(Color("BasketballOrange"))

                    if let ageGroup = team.ageGroup {
                        Text(ageGroup)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    if let season = team.season {
                        Text(season)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("BasketballOrange"))
            }
        }
        .padding()
        .background(isSelected ? Color.gray.opacity(0.2) : Color("CoachBlack"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct TeamDetailsSection: View {
    let team: TeamData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team Details")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 8) {
                DetailRow(label: "Organization", value: team.organization ?? "N/A")
                DetailRow(label: "Primary Color", value: team.primaryColor ?? "#007AFF")
                DetailRow(label: "Secondary Color", value: team.secondaryColor ?? "#FF3B30")
                DetailRow(label: "Created", value: formatDate(team.createdAt))
            }
        }
        .padding()
        .background(Color("CoachBlack"))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Data Models for Supabase

struct TeamData: Codable, Identifiable {
    let id: UUID
    let name: String
    let teamCode: String
    let organization: String?
    let ageGroup: String?
    let season: String?
    let primaryColor: String?
    let secondaryColor: String?
    let logoUrl: String?
    let createdAt: Date?
    let updatedAt: Date?
}

struct PlayerData: Codable, Identifiable {
    let id: UUID
    let teamId: UUID
    let jerseyNumber: String
    let firstName: String
    let lastName: String
    let position: String?
    let height: String?
    let weight: String?
    let dateOfBirth: Date?
    let parentName: String?
    let parentEmail: String?
    let parentPhone: String?
    let emergencyContact: String?
    let medicalNotes: String?
    let photoUrl: String?
    let isActive: Bool?
    let createdAt: Date?
    let updatedAt: Date?
}

struct ScheduleData: Codable, Identifiable {
    let id: UUID
    let teamId: UUID
    let title: String
    let eventType: String
    let startTime: Date
    let endTime: Date?
    let location: String?
    let address: String?
    let opponent: String?
    let isHomeGame: Bool?
    let notes: String?
    let result: String?
    let teamScore: Int?
    let opponentScore: Int?
    let createdAt: Date?
    let updatedAt: Date?
}