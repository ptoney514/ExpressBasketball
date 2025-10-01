//
//  SupabaseService.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import Foundation
import Supabase
import Combine

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    private(set) var client: SupabaseClient

    private init() {
        let config = ConfigurationManager.shared

        client = SupabaseClient(
            supabaseURL: config.supabaseURL,
            supabaseKey: config.supabaseAnonKey
        )

        ConfigurationManager.shared.log("✅ Supabase client initialized", level: .info)
    }

    func fetchTeam(withCode teamCode: String) async throws -> TeamResponse {
        ConfigurationManager.shared.log("🔍 Fetching team with code: \(teamCode)", level: .debug)

        let response = try await client
            .from("teams")
            .select("*")
            .eq("team_code", value: teamCode)
            .single()
            .execute()

        let team = try JSONDecoder().decode(TeamResponse.self, from: response.data)

        ConfigurationManager.shared.log("✅ Team fetched: \(team.name)", level: .info)
        return team
    }

    func fetchPlayers(forTeamId teamId: UUID) async throws -> [PlayerResponse] {
        ConfigurationManager.shared.log("🔍 Fetching players for team: \(teamId)", level: .debug)

        let response = try await client
            .from("players")
            .select("*")
            .eq("team_id", value: teamId.uuidString)
            .order("jersey_number", ascending: true)
            .execute()

        let players = try JSONDecoder().decode([PlayerResponse].self, from: response.data)

        ConfigurationManager.shared.log("✅ Fetched \(players.count) players", level: .info)
        return players
    }

    func fetchSchedules(forTeamId teamId: UUID) async throws -> [ScheduleResponse] {
        ConfigurationManager.shared.log("🔍 Fetching schedules for team: \(teamId)", level: .debug)

        let response = try await client
            .from("schedules")
            .select("*")
            .eq("team_id", value: teamId.uuidString)
            .order("start_time", ascending: true)
            .execute()

        let schedules = try JSONDecoder().decode([ScheduleResponse].self, from: response.data)

        ConfigurationManager.shared.log("✅ Fetched \(schedules.count) schedules", level: .info)
        return schedules
    }

    func fetchAnnouncements(forTeamId teamId: UUID) async throws -> [AnnouncementResponse] {
        ConfigurationManager.shared.log("🔍 Fetching announcements for team: \(teamId)", level: .debug)

        let response = try await client
            .from("announcements")
            .select("*")
            .eq("team_id", value: teamId.uuidString)
            .order("created_at", ascending: false)
            .execute()

        let announcements = try JSONDecoder().decode([AnnouncementResponse].self, from: response.data)

        ConfigurationManager.shared.log("✅ Fetched \(announcements.count) announcements", level: .info)
        return announcements
    }

    func subscribeToTeamUpdates(teamId: UUID, onUpdate: @escaping () -> Void) {
        Task {
            do {
                let channel = client.realtimeV2.channel("team-updates-\(teamId)")

                ConfigurationManager.shared.log("📡 Subscribing to updates for team: \(teamId)", level: .info)

                let _ = channel.onPostgresChange(
                    AnyAction.self,
                    schema: "public",
                    table: "announcements",
                    filter: "team_id=eq.\(teamId)"
                ) { _ in
                    ConfigurationManager.shared.log("📢 Announcement changed", level: .debug)
                    onUpdate()
                }

                let _ = channel.onPostgresChange(
                    AnyAction.self,
                    schema: "public",
                    table: "schedules",
                    filter: "team_id=eq.\(teamId)"
                ) { _ in
                    ConfigurationManager.shared.log("📅 Schedule changed", level: .debug)
                    onUpdate()
                }

                let _ = channel.onPostgresChange(
                    AnyAction.self,
                    schema: "public",
                    table: "players",
                    filter: "team_id=eq.\(teamId)"
                ) { _ in
                    ConfigurationManager.shared.log("👤 Player changed", level: .debug)
                    onUpdate()
                }

                try await channel.subscribeWithError()
            } catch {
                ConfigurationManager.shared.log("❌ Failed to subscribe: \(error)", level: .error)
            }
        }
    }
}

// MARK: - Response Models

struct TeamResponse: Codable {
    let id: UUID
    let name: String
    let teamCode: String
    let organization: String?
    let ageGroup: String?
    let season: String?
    let primaryColor: String?
    let secondaryColor: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case teamCode = "team_code"
        case organization
        case ageGroup = "age_group"
        case season
        case primaryColor = "primary_color"
        case secondaryColor = "secondary_color"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PlayerResponse: Codable {
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
    let isActive: Bool
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case jerseyNumber = "jersey_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case position
        case height
        case weight
        case dateOfBirth = "date_of_birth"
        case parentName = "parent_name"
        case parentEmail = "parent_email"
        case parentPhone = "parent_phone"
        case emergencyContact = "emergency_contact"
        case medicalNotes = "medical_notes"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ScheduleResponse: Codable {
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

    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case title
        case eventType = "event_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case location
        case address
        case opponent
        case isHomeGame = "is_home_game"
        case notes
        case result
        case teamScore = "team_score"
        case opponentScore = "opponent_score"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AnnouncementResponse: Codable {
    let id: UUID
    let teamId: UUID
    let title: String
    let content: String
    let priority: String
    let isPinned: Bool
    let expiresAt: Date?
    let createdBy: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case title
        case content
        case priority
        case isPinned = "is_pinned"
        case expiresAt = "expires_at"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum SupabaseError: Error {
    case clientNotInitialized
    case invalidTeamCode
    case networkError
    case decodingError
}