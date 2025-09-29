//
//  DataService.swift
//  ExpressCoach
//
//  Protocol abstraction for data services to enable testing and backend flexibility
//

import Foundation
import SwiftData

// MARK: - Data Service Protocol
protocol DataService {
    // Team operations
    func fetchTeams() async throws -> [Team]
    func fetchTeam(id: UUID) async throws -> Team?
    func createTeam(_ team: Team) async throws -> Team
    func updateTeam(_ team: Team) async throws -> Team
    func deleteTeam(id: UUID) async throws
    
    // Player operations
    func fetchPlayers(for teamId: UUID) async throws -> [Player]
    func fetchPlayer(id: UUID) async throws -> Player?
    func createPlayer(_ player: Player) async throws -> Player
    func updatePlayer(_ player: Player) async throws -> Player
    func deletePlayer(id: UUID) async throws
    
    // Schedule operations
    func fetchSchedules(for teamId: UUID) async throws -> [Schedule]
    func fetchSchedule(id: UUID) async throws -> Schedule?
    func createSchedule(_ schedule: Schedule) async throws -> Schedule
    func updateSchedule(_ schedule: Schedule) async throws -> Schedule
    func deleteSchedule(id: UUID) async throws
    
    // Event operations
    func fetchEvents(for teamId: UUID) async throws -> [Event]
    func fetchEvent(id: UUID) async throws -> Event?
    func createEvent(_ event: Event) async throws -> Event
    func updateEvent(_ event: Event) async throws -> Event
    func deleteEvent(id: UUID) async throws
    
    // Announcement operations
    func fetchAnnouncements(for teamId: UUID) async throws -> [Announcement]
    func fetchAnnouncement(id: UUID) async throws -> Announcement?
    func createAnnouncement(_ announcement: Announcement) async throws -> Announcement
    func updateAnnouncement(_ announcement: Announcement) async throws -> Announcement
    func deleteAnnouncement(id: UUID) async throws
    
    // Sync operations
    func performFullSync() async throws
    func subscribeToRealtimeUpdates()
    func unsubscribeFromRealtimeUpdates()
}

// MARK: - Data Service Error
enum DataServiceError: LocalizedError {
    case networkError(String)
    case notFound
    case unauthorized
    case validationError(String)
    case syncError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .notFound:
            return "The requested item was not found"
        case .unauthorized:
            return "You are not authorized to perform this action"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .syncError(let message):
            return "Sync error: \(message)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Mock Data Service for Testing
@MainActor
class MockDataService: DataService {
    private var teams: [Team] = []
    private var players: [UUID: [Player]] = [:]
    private var schedules: [UUID: [Schedule]] = [:]
    private var events: [UUID: [Event]] = [:]
    private var announcements: [UUID: [Announcement]] = [:]
    
    // MARK: - Team Operations
    func fetchTeams() async throws -> [Team] {
        return teams
    }
    
    func fetchTeam(id: UUID) async throws -> Team? {
        return teams.first { $0.id == id }
    }
    
    func createTeam(_ team: Team) async throws -> Team {
        teams.append(team)
        return team
    }
    
    func updateTeam(_ team: Team) async throws -> Team {
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            teams[index] = team
            return team
        }
        throw DataServiceError.notFound
    }
    
    func deleteTeam(id: UUID) async throws {
        teams.removeAll { $0.id == id }
        players[id] = nil
        schedules[id] = nil
        events[id] = nil
        announcements[id] = nil
    }
    
    // MARK: - Player Operations
    func fetchPlayers(for teamId: UUID) async throws -> [Player] {
        return players[teamId] ?? []
    }
    
    func fetchPlayer(id: UUID) async throws -> Player? {
        for (_, teamPlayers) in players {
            if let player = teamPlayers.first(where: { $0.id == id }) {
                return player
            }
        }
        return nil
    }
    
    func createPlayer(_ player: Player) async throws -> Player {
        guard let teamId = player.team?.id else {
            throw DataServiceError.validationError("Player must have a team")
        }
        
        if players[teamId] == nil {
            players[teamId] = []
        }
        players[teamId]?.append(player)
        return player
    }
    
    func updatePlayer(_ player: Player) async throws -> Player {
        guard let teamId = player.team?.id else {
            throw DataServiceError.validationError("Player must have a team")
        }
        
        if let index = players[teamId]?.firstIndex(where: { $0.id == player.id }) {
            players[teamId]?[index] = player
            return player
        }
        throw DataServiceError.notFound
    }
    
    func deletePlayer(id: UUID) async throws {
        for (teamId, var teamPlayers) in players {
            if let index = teamPlayers.firstIndex(where: { $0.id == id }) {
                teamPlayers.remove(at: index)
                players[teamId] = teamPlayers
                return
            }
        }
        throw DataServiceError.notFound
    }
    
    // MARK: - Schedule Operations
    func fetchSchedules(for teamId: UUID) async throws -> [Schedule] {
        return schedules[teamId] ?? []
    }
    
    func fetchSchedule(id: UUID) async throws -> Schedule? {
        for (_, teamSchedules) in schedules {
            if let schedule = teamSchedules.first(where: { $0.id == id }) {
                return schedule
            }
        }
        return nil
    }
    
    func createSchedule(_ schedule: Schedule) async throws -> Schedule {
        guard let teamId = schedule.team?.id else {
            throw DataServiceError.validationError("Schedule must have a team")
        }
        
        if schedules[teamId] == nil {
            schedules[teamId] = []
        }
        schedules[teamId]?.append(schedule)
        return schedule
    }
    
    func updateSchedule(_ schedule: Schedule) async throws -> Schedule {
        guard let teamId = schedule.team?.id else {
            throw DataServiceError.validationError("Schedule must have a team")
        }
        
        if let index = schedules[teamId]?.firstIndex(where: { $0.id == schedule.id }) {
            schedules[teamId]?[index] = schedule
            return schedule
        }
        throw DataServiceError.notFound
    }
    
    func deleteSchedule(id: UUID) async throws {
        for (teamId, var teamSchedules) in schedules {
            if let index = teamSchedules.firstIndex(where: { $0.id == id }) {
                teamSchedules.remove(at: index)
                schedules[teamId] = teamSchedules
                return
            }
        }
        throw DataServiceError.notFound
    }
    
    // MARK: - Event Operations
    func fetchEvents(for teamId: UUID) async throws -> [Event] {
        return events[teamId] ?? []
    }
    
    func fetchEvent(id: UUID) async throws -> Event? {
        for (_, teamEvents) in events {
            if let event = teamEvents.first(where: { $0.id == id }) {
                return event
            }
        }
        return nil
    }
    
    func createEvent(_ event: Event) async throws -> Event {
        guard let teamId = event.schedule?.team?.id else {
            throw DataServiceError.validationError("Event must have a schedule with a team")
        }
        
        if events[teamId] == nil {
            events[teamId] = []
        }
        events[teamId]?.append(event)
        return event
    }
    
    func updateEvent(_ event: Event) async throws -> Event {
        guard let teamId = event.schedule?.team?.id else {
            throw DataServiceError.validationError("Event must have a schedule with a team")
        }
        
        if let index = events[teamId]?.firstIndex(where: { $0.id == event.id }) {
            events[teamId]?[index] = event
            return event
        }
        throw DataServiceError.notFound
    }
    
    func deleteEvent(id: UUID) async throws {
        for (teamId, var teamEvents) in events {
            if let index = teamEvents.firstIndex(where: { $0.id == id }) {
                teamEvents.remove(at: index)
                events[teamId] = teamEvents
                return
            }
        }
        throw DataServiceError.notFound
    }
    
    // MARK: - Announcement Operations
    func fetchAnnouncements(for teamId: UUID) async throws -> [Announcement] {
        return announcements[teamId] ?? []
    }
    
    func fetchAnnouncement(id: UUID) async throws -> Announcement? {
        for (_, teamAnnouncements) in announcements {
            if let announcement = teamAnnouncements.first(where: { $0.id == id }) {
                return announcement
            }
        }
        return nil
    }
    
    func createAnnouncement(_ announcement: Announcement) async throws -> Announcement {
        guard let teamId = announcement.team?.id else {
            throw DataServiceError.validationError("Announcement must have a team")
        }
        
        if announcements[teamId] == nil {
            announcements[teamId] = []
        }
        announcements[teamId]?.append(announcement)
        return announcement
    }
    
    func updateAnnouncement(_ announcement: Announcement) async throws -> Announcement {
        guard let teamId = announcement.team?.id else {
            throw DataServiceError.validationError("Announcement must have a team")
        }
        
        if let index = announcements[teamId]?.firstIndex(where: { $0.id == announcement.id }) {
            announcements[teamId]?[index] = announcement
            return announcement
        }
        throw DataServiceError.notFound
    }
    
    func deleteAnnouncement(id: UUID) async throws {
        for (teamId, var teamAnnouncements) in announcements {
            if let index = teamAnnouncements.firstIndex(where: { $0.id == id }) {
                teamAnnouncements.remove(at: index)
                announcements[teamId] = teamAnnouncements
                return
            }
        }
        throw DataServiceError.notFound
    }
    
    // MARK: - Sync Operations
    func performFullSync() async throws {
        // Mock implementation - no actual syncing needed
        print("Mock: Performing full sync")
    }
    
    func subscribeToRealtimeUpdates() {
        // Mock implementation - no actual subscription needed
        print("Mock: Subscribing to realtime updates")
    }
    
    func unsubscribeFromRealtimeUpdates() {
        // Mock implementation - no actual unsubscription needed
        print("Mock: Unsubscribing from realtime updates")
    }
}