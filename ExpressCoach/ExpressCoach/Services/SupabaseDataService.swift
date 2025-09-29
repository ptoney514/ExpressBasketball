//
//  SupabaseDataService.swift
//  ExpressCoach
//
//  Supabase implementation of the DataService protocol
//

import Foundation
import Supabase
import SwiftData

@MainActor
class SupabaseDataService: DataService {
    private let supabase: SupabaseClient
    private var realtimeSubscriptions: [RealtimeChannel] = []
    
    init() {
        let config = ConfigurationManager.shared
        self.supabase = SupabaseClient(
            supabaseURL: config.environment.supabaseURL,
            supabaseKey: config.environment.supabaseAnonKey
        )
    }
    
    // MARK: - Team Operations
    func fetchTeams() async throws -> [Team] {
        let response = try await supabase
            .from("teams")
            .select()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let teamDTOs = try decoder.decode([TeamDTO].self, from: response.data)
        return teamDTOs.map { $0.toModel() }
    }
    
    func fetchTeam(id: UUID) async throws -> Team? {
        let response = try await supabase
            .from("teams")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let teamDTO = try? decoder.decode(TeamDTO.self, from: response.data)
        return teamDTO?.toModel()
    }
    
    func createTeam(_ team: Team) async throws -> Team {
        let teamDTO = TeamDTO(fromModel: team)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let teamData = try encoder.encode(teamDTO)
        
        let response = try await supabase
            .from("teams")
            .insert(teamData)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resultDTO = try decoder.decode(TeamDTO.self, from: response.data)
        return resultDTO.toModel()
    }
    
    func updateTeam(_ team: Team) async throws -> Team {
        let teamDTO = TeamDTO(fromModel: team)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let teamData = try encoder.encode(teamDTO)
        
        let response = try await supabase
            .from("teams")
            .update(teamData)
            .eq("id", value: team.id.uuidString)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resultDTO = try decoder.decode(TeamDTO.self, from: response.data)
        return resultDTO.toModel()
    }
    
    func deleteTeam(id: UUID) async throws {
        _ = try await supabase
            .from("teams")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Player Operations
    func fetchPlayers(for teamId: UUID) async throws -> [Player] {
        let response = try await supabase
            .from("players")
            .select()
            .eq("team_id", value: teamId.uuidString)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let playerDTOs = try decoder.decode([PlayerDTO].self, from: response.data)
        return playerDTOs.map { $0.toModel() }
    }
    
    func fetchPlayer(id: UUID) async throws -> Player? {
        let response = try await supabase
            .from("players")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let playerDTO = try? decoder.decode(PlayerDTO.self, from: response.data)
        return playerDTO?.toModel()
    }
    
    func createPlayer(_ player: Player) async throws -> Player {
        let playerDTO = PlayerDTO(fromModel: player)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let playerData = try encoder.encode(playerDTO)
        
        let response = try await supabase
            .from("players")
            .insert(playerData)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resultDTO = try decoder.decode(PlayerDTO.self, from: response.data)
        return resultDTO.toModel()
    }
    
    func updatePlayer(_ player: Player) async throws -> Player {
        let playerDTO = PlayerDTO(fromModel: player)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let playerData = try encoder.encode(playerDTO)
        
        let response = try await supabase
            .from("players")
            .update(playerData)
            .eq("id", value: player.id.uuidString)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resultDTO = try decoder.decode(PlayerDTO.self, from: response.data)
        return resultDTO.toModel()
    }
    
    func deletePlayer(id: UUID) async throws {
        _ = try await supabase
            .from("players")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Schedule Operations
    func fetchSchedules(for teamId: UUID) async throws -> [Schedule] {
        let response = try await supabase
            .from("schedules")
            .select()
            .eq("team_id", value: teamId.uuidString)
            .order("start_time")
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let scheduleDTOs = try decoder.decode([ScheduleDTO].self, from: response.data)
        return scheduleDTOs.map { $0.toModel() }
    }
    
    func fetchSchedule(id: UUID) async throws -> Schedule? {
        let response = try await supabase
            .from("schedules")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let scheduleDTO = try? decoder.decode(ScheduleDTO.self, from: response.data)
        return scheduleDTO?.toModel()
    }
    
    func createSchedule(_ schedule: Schedule) async throws -> Schedule {
        let scheduleDTO = ScheduleDTO(fromModel: schedule)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let scheduleData = try encoder.encode(scheduleDTO)
        
        let response = try await supabase
            .from("schedules")
            .insert(scheduleData)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let resultDTO = try decoder.decode(ScheduleDTO.self, from: response.data)
        return resultDTO.toModel()
    }
    
    func updateSchedule(_ schedule: Schedule) async throws -> Schedule {
        let scheduleDTO = ScheduleDTO(fromModel: schedule)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let scheduleData = try encoder.encode(scheduleDTO)
        
        let response = try await supabase
            .from("schedules")
            .update(scheduleData)
            .eq("id", value: schedule.id.uuidString)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let resultDTO = try decoder.decode(ScheduleDTO.self, from: response.data)
        return resultDTO.toModel()
    }
    
    func deleteSchedule(id: UUID) async throws {
        _ = try await supabase
            .from("schedules")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Event Operations
    func fetchEvents(for teamId: UUID) async throws -> [Event] {
        let response = try await supabase
            .from("events")
            .select()
            .eq("team_id", value: teamId.uuidString)
            .order("start_date")
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let eventDTOs = try decoder.decode([EventDTO].self, from: response.data)
        return eventDTOs.map { $0.toModel() }
    }
    
    func fetchEvent(id: UUID) async throws -> Event? {
        let response = try await supabase
            .from("events")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let eventDTO = try? decoder.decode(EventDTO.self, from: response.data)
        return eventDTO?.toModel()
    }
    
    func createEvent(_ event: Event) async throws -> Event {
        let eventDTO = EventDTO(fromModel: event)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let eventData = try encoder.encode(eventDTO)
        
        let response = try await supabase
            .from("events")
            .insert(eventData)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let resultDTO = try decoder.decode(EventDTO.self, from: response.data)
        return resultDTO.toModel()
    }
    
    func updateEvent(_ event: Event) async throws -> Event {
        let eventDTO = EventDTO(fromModel: event)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let eventData = try encoder.encode(eventDTO)
        
        let response = try await supabase
            .from("events")
            .update(eventData)
            .eq("id", value: event.id.uuidString)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let resultDTO = try decoder.decode(EventDTO.self, from: response.data)
        return resultDTO.toModel()
    }
    
    func deleteEvent(id: UUID) async throws {
        _ = try await supabase
            .from("events")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Announcement Operations
    func fetchAnnouncements(for teamId: UUID) async throws -> [Announcement] {
        let response = try await supabase
            .from("announcements")
            .select()
            .eq("team_id", value: teamId.uuidString)
            .order("created_at", ascending: false)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let announcementDTOs = try decoder.decode([AnnouncementDTO].self, from: response.data)
        return announcementDTOs.map { $0.toModel() }
    }
    
    func fetchAnnouncement(id: UUID) async throws -> Announcement? {
        let response = try await supabase
            .from("announcements")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let announcementDTO = try? decoder.decode(AnnouncementDTO.self, from: response.data)
        return announcementDTO?.toModel()
    }
    
    func createAnnouncement(_ announcement: Announcement) async throws -> Announcement {
        let announcementDTO = AnnouncementDTO(fromModel: announcement)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let announcementData = try encoder.encode(announcementDTO)
        
        let response = try await supabase
            .from("announcements")
            .insert(announcementData)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let resultDTO = try decoder.decode(AnnouncementDTO.self, from: response.data)
        return resultDTO.toModel()
    }
    
    func updateAnnouncement(_ announcement: Announcement) async throws -> Announcement {
        let announcementDTO = AnnouncementDTO(fromModel: announcement)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let announcementData = try encoder.encode(announcementDTO)
        
        let response = try await supabase
            .from("announcements")
            .update(announcementData)
            .eq("id", value: announcement.id.uuidString)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let resultDTO = try decoder.decode(AnnouncementDTO.self, from: response.data)
        return resultDTO.toModel()
    }
    
    func deleteAnnouncement(id: UUID) async throws {
        _ = try await supabase
            .from("announcements")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Sync Operations
    func performFullSync() async throws {
        // Implementation for full sync
        // This would typically:
        // 1. Fetch all data from remote
        // 2. Update local cache
        // 3. Handle conflicts
        print("Performing full sync with Supabase")
    }
    
    func subscribeToRealtimeUpdates() {
        // TODO: Implement realtime updates using RealtimeChannelV2
        // The old RealtimeChannel is deprecated and needs migration
        print("Realtime updates not yet implemented")
    }
    
    func unsubscribeFromRealtimeUpdates() {
        // TODO: Implement cleanup when RealtimeChannelV2 is set up
        realtimeSubscriptions.removeAll()
    }
}