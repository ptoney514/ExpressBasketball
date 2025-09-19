//
//  SupabaseService.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import Foundation
import Supabase

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    private var client: SupabaseClient?

    private init() {
        setupClient()
    }

    private func setupClient() {
        guard let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let supabaseAnonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] else {
            print("Warning: Supabase credentials not configured")
            return
        }

        guard let url = URL(string: supabaseURL) else {
            print("Invalid Supabase URL")
            return
        }

        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseAnonKey
        )
    }

    func fetchTeam(withCode teamCode: String) async throws -> TeamResponse? {
        guard let client = client else {
            throw SupabaseError.clientNotInitialized
        }

        let response: TeamResponse = try await client
            .from("teams")
            .select("*")
            .eq("team_code", value: teamCode)
            .single()
            .execute()
            .value

        return response
    }

    func subscribeToTeamUpdates(teamId: UUID) {
        guard let client = client else { return }

        Task {
            let channel = client.realtimeV2.channel("team-\(teamId)")

            await channel
                .onPostgresChange(
                    event: .all,
                    schema: "public",
                    table: "announcements",
                    filter: "team_id=eq.\(teamId)"
                ) { payload in
                    self.handleAnnouncementChange(payload)
                }
                .onPostgresChange(
                    event: .all,
                    schema: "public",
                    table: "schedules",
                    filter: "team_id=eq.\(teamId)"
                ) { payload in
                    self.handleScheduleChange(payload)
                }
                .subscribe()
        }
    }

    private func handleAnnouncementChange(_ payload: PostgresChangePayload) {
        switch payload.event {
        case .insert:
            print("New announcement")
        case .update:
            print("Updated announcement")
        case .delete:
            print("Deleted announcement")
        default:
            break
        }
    }

    private func handleScheduleChange(_ payload: PostgresChangePayload) {
        switch payload.event {
        case .insert:
            print("New schedule event")
        case .update:
            print("Updated schedule event")
        case .delete:
            print("Deleted schedule event")
        default:
            break
        }
    }
}

struct TeamResponse: Codable {
    let id: UUID
    let name: String
    let ageGroup: String
    let season: String
    let teamCode: String
    let primaryColor: String
    let secondaryColor: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case ageGroup = "age_group"
        case season
        case teamCode = "team_code"
        case primaryColor = "primary_color"
        case secondaryColor = "secondary_color"
    }
}

enum SupabaseError: Error {
    case clientNotInitialized
    case invalidTeamCode
    case networkError
}