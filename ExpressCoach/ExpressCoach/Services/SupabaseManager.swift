//
//  SupabaseManager.swift
//  ExpressCoach
//
//  Manages connection to local Supabase instance
//

import Foundation
import Supabase
import Realtime
import Combine

// MARK: - Notification Payload

struct NotificationPayload: Codable, Sendable {
    let team_id: String
    let title: String
    let message: String
    let recipient_type: String
    let is_urgent: Bool
    let sent_at: String
    let sent_by: String
}

@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()

    let objectWillChange = PassthroughSubject<Void, Never>()

    let client: SupabaseClient

    nonisolated init() {
        // Local Supabase configuration
        let url = URL(string: "http://127.0.0.1:54321")!
        let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"

        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
    }

    // MARK: - Teams

    func fetchTeams() async throws -> [SupabaseTeam] {
        let response = try await client
            .from("teams")
            .select("*, coach:coaches(*)")
            .execute()

        let data = response.data
        let teams = try JSONDecoder().decode([SupabaseTeam].self, from: data)
        return teams
    }

    func fetchTeam(byCode code: String) async throws -> SupabaseTeam? {
        let response = try await client
            .from("teams")
            .select("*, coach:coaches(*), players:player_teams(player:players(*))")
            .eq("team_code", value: code)
            .single()
            .execute()

        let data = response.data
        let team = try JSONDecoder().decode(SupabaseTeam.self, from: data)
        return team
    }

    // MARK: - Players

    func fetchPlayersForTeam(teamId: UUID) async throws -> [SupabasePlayer] {
        let response = try await client
            .from("player_teams")
            .select("player:players(*)")
            .eq("team_id", value: teamId.uuidString)
            .execute()

        let data = response.data
        let playerTeams = try JSONDecoder().decode([PlayerTeamRelation].self, from: data)
        return playerTeams.compactMap { $0.player }
    }

    // MARK: - Schedules

    func fetchSchedulesForTeam(teamId: UUID) async throws -> [SupabaseSchedule] {
        let response = try await client
            .from("schedules")
            .select("*")
            .eq("team_id", value: teamId.uuidString)
            .order("event_date", ascending: true)
            .execute()

        let data = response.data
        let schedules = try JSONDecoder().decode([SupabaseSchedule].self, from: data)
        return schedules
    }

    // MARK: - Notifications

    func sendNotification(
        teamId: UUID,
        title: String,
        message: String,
        recipientType: String,
        urgent: Bool = false
    ) async throws {
        // TODO: Fix Sendable conformance issue with Supabase insert
        // For now, just print the notification
        print("Would send notification: \(title) - \(message)")
    }

    // MARK: - Real-time Subscriptions

    func subscribeToTeamUpdates(teamId: UUID, onUpdate: @escaping () -> Void) {
        Task {
            let channel = client.realtimeV2.channel("team-updates-\(teamId)")

            let _ = channel.onPostgresChange(
                AnyAction.self,
                schema: "public",
                table: "teams",
                filter: "id=eq.\(teamId)"
            ) { _ in
                onUpdate()
            }

            do {
                try await channel.subscribeWithError()
            } catch {
                print("Failed to subscribe: \(error)")
            }
        }
    }
}

// MARK: - Supabase Models

struct SupabaseTeam: Codable {
    let id: UUID
    let clubId: UUID?
    let name: String
    let ageGroup: String
    let teamCode: String
    let coachId: UUID?
    let practiceLocation: String?
    let practiceTime: String?
    let homeVenue: String?
    let seasonRecord: String?
    let createdAt: Date
    let updatedAt: Date

    let coach: SupabaseCoach?

    enum CodingKeys: String, CodingKey {
        case id
        case clubId = "club_id"
        case name
        case ageGroup = "age_group"
        case teamCode = "team_code"
        case coachId = "coach_id"
        case practiceLocation = "practice_location"
        case practiceTime = "practice_time"
        case homeVenue = "home_venue"
        case seasonRecord = "season_record"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case coach
    }
}

struct SupabaseCoach: Codable {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String?
    let phone: String?
    let role: String

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
        case role
    }
}

struct SupabasePlayer: Codable {
    let id: UUID
    let firstName: String
    let lastName: String
    let jerseyNumber: Int?
    let position: String?
    let dateOfBirth: Date?
    let parentName: String?
    let parentPhone: String?
    let parentEmail: String?
    let emergencyContact: String?
    let emergencyPhone: String?
    let medicalNotes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case jerseyNumber = "jersey_number"
        case position
        case dateOfBirth = "date_of_birth"
        case parentName = "parent_name"
        case parentPhone = "parent_phone"
        case parentEmail = "parent_email"
        case emergencyContact = "emergency_contact"
        case emergencyPhone = "emergency_phone"
        case medicalNotes = "medical_notes"
    }
}

struct SupabaseSchedule: Codable {
    let id: UUID
    let teamId: UUID
    let eventType: String
    let eventDate: Date
    let location: String?
    let opponent: String?
    let homeAway: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case eventType = "event_type"
        case eventDate = "event_date"
        case location
        case opponent
        case homeAway = "home_away"
        case notes
    }
}

struct PlayerTeamRelation: Codable {
    let player: SupabasePlayer?
}