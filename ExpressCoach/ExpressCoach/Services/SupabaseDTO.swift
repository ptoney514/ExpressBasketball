//
//  SupabaseDTO.swift
//  ExpressCoach
//
//  Data Transfer Objects for Supabase API communication
//

import Foundation

// MARK: - Team DTO
struct TeamDTO: Codable, Sendable {
    let id: UUID
    let teamCode: String
    let name: String
    let ageGroup: String
    let coachName: String
    let coachRole: String
    let assistantCoaches: [String]
    let primaryColor: String
    let secondaryColor: String
    let logoURL: String?
    let practiceLocation: String?
    let practiceTime: String?
    let homeVenue: String?
    let seasonRecord: String?
    let wins: Int
    let losses: Int
    let organization: String?
    let season: String?
    let coachEmail: String?
    let coachPhone: String?
    let createdAt: Date
    let updatedAt: Date
    let isActive: Bool
    let lastSyncedAt: Date?
    let syncVersion: Int
    
    init(fromModel team: Team) {
        self.id = team.id
        self.teamCode = team.teamCode
        self.name = team.name
        self.ageGroup = team.ageGroup
        self.coachName = team.coachName
        self.coachRole = team.coachRole.rawValue
        self.assistantCoaches = team.assistantCoaches
        self.primaryColor = team.primaryColor
        self.secondaryColor = team.secondaryColor
        self.logoURL = team.logoURL
        self.practiceLocation = team.practiceLocation
        self.practiceTime = team.practiceTime
        self.homeVenue = team.homeVenue
        self.seasonRecord = team.seasonRecord
        self.wins = team.wins
        self.losses = team.losses
        self.organization = team.organization
        self.season = team.season
        self.coachEmail = team.coachEmail
        self.coachPhone = team.coachPhone
        self.createdAt = team.createdAt
        self.updatedAt = team.updatedAt
        self.isActive = team.isActive
        self.lastSyncedAt = team.lastSyncedAt
        self.syncVersion = team.syncVersion
    }
    
    func toModel() -> Team {
        let team = Team(
            name: name,
            teamCode: teamCode,
            organization: organization ?? "",
            ageGroup: ageGroup,
            season: season ?? ""
        )
        team.id = id
        team.coachName = coachName
        team.coachRole = CoachRole(rawValue: coachRole) ?? .headCoach
        team.assistantCoaches = assistantCoaches
        team.primaryColor = primaryColor
        team.secondaryColor = secondaryColor
        team.logoURL = logoURL
        team.practiceLocation = practiceLocation
        team.practiceTime = practiceTime
        team.homeVenue = homeVenue
        team.seasonRecord = seasonRecord
        team.wins = wins
        team.losses = losses
        team.coachEmail = coachEmail
        team.coachPhone = coachPhone
        team.createdAt = createdAt
        team.updatedAt = updatedAt
        team.isActive = isActive
        team.lastSyncedAt = lastSyncedAt
        team.syncVersion = syncVersion
        return team
    }
}

// MARK: - Player DTO
struct PlayerDTO: Codable, Sendable {
    let id: UUID
    let firstName: String
    let lastName: String
    let jerseyNumber: String
    let position: String
    let height: String?
    let weight: String?
    let graduationYear: Int
    let birthDate: Date?
    let parentName: String?
    let parentEmail: String?
    let parentPhone: String?
    let emergencyContact: String?
    let emergencyPhone: String?
    let medicalNotes: String?
    let photoURL: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let lastSyncedAt: Date?
    let syncVersion: Int
    let teamId: UUID?
    
    init(fromModel player: Player) {
        self.id = player.id
        self.firstName = player.firstName
        self.lastName = player.lastName
        self.jerseyNumber = player.jerseyNumber
        self.position = player.position
        self.height = player.height
        self.weight = player.weight
        self.graduationYear = player.graduationYear
        self.birthDate = player.birthDate
        self.parentName = player.parentName
        self.parentEmail = player.parentEmail
        self.parentPhone = player.parentPhone
        self.emergencyContact = player.emergencyContact
        self.emergencyPhone = player.emergencyPhone
        self.medicalNotes = player.medicalNotes
        self.photoURL = player.photoURL
        self.isActive = player.isActive
        self.createdAt = player.createdAt
        self.updatedAt = player.updatedAt
        self.lastSyncedAt = player.lastSyncedAt
        self.syncVersion = player.syncVersion
        self.teamId = player.team?.id
    }
    
    func toModel() -> Player {
        let player = Player(
            firstName: firstName,
            lastName: lastName,
            jerseyNumber: jerseyNumber,
            position: position,
            graduationYear: graduationYear,
            parentName: parentName ?? "",
            parentEmail: parentEmail ?? "",
            parentPhone: parentPhone ?? "",
            emergencyContact: emergencyContact ?? "",
            emergencyPhone: emergencyPhone ?? ""
        )
        player.id = id
        player.height = height
        player.weight = weight
        player.birthDate = birthDate
        player.medicalNotes = medicalNotes
        player.photoURL = photoURL
        player.isActive = isActive
        player.createdAt = createdAt
        player.updatedAt = updatedAt
        player.lastSyncedAt = lastSyncedAt
        player.syncVersion = syncVersion
        return player
    }
}

// MARK: - Schedule DTO
struct ScheduleDTO: Codable, Sendable {
    let id: UUID
    let eventType: String
    let opponent: String?
    let location: String
    let address: String?
    let date: Date
    let arrivalTime: Date?
    let isHome: Bool
    let notes: String?
    let result: String?
    let teamScore: Int?
    let opponentScore: Int?
    let isCancelled: Bool
    let createdAt: Date
    let updatedAt: Date
    let teamId: UUID?
    
    init(fromModel schedule: Schedule) {
        self.id = schedule.id
        self.eventType = schedule.eventType.rawValue
        self.opponent = schedule.opponent
        self.location = schedule.location
        self.address = schedule.address
        self.date = schedule.date
        self.arrivalTime = schedule.arrivalTime
        self.isHome = schedule.isHome
        self.notes = schedule.notes
        self.result = schedule.result?.rawValue
        self.teamScore = schedule.teamScore
        self.opponentScore = schedule.opponentScore
        self.isCancelled = schedule.isCancelled
        self.createdAt = schedule.createdAt
        self.updatedAt = schedule.updatedAt
        self.teamId = schedule.team?.id
    }
    
    func toModel() -> Schedule {
        let schedule = Schedule(
            eventType: Schedule.EventType(rawValue: eventType) ?? .game,
            location: location,
            date: date,
            isHome: isHome
        )
        schedule.id = id
        schedule.opponent = opponent
        schedule.address = address
        schedule.arrivalTime = arrivalTime
        schedule.notes = notes
        schedule.result = result != nil ? Schedule.GameResult(rawValue: result!) : nil
        schedule.teamScore = teamScore
        schedule.opponentScore = opponentScore
        schedule.isCancelled = isCancelled
        schedule.createdAt = createdAt
        schedule.updatedAt = updatedAt
        return schedule
    }
}

// MARK: - Event DTO
struct EventDTO: Codable, Sendable {
    let id: UUID
    let title: String
    let eventDescription: String?
    let date: Date
    let endDate: Date?
    let location: String?
    let address: String?
    let isAllDay: Bool
    let reminderMinutes: Int?
    let createdAt: Date
    let updatedAt: Date
    let scheduleId: UUID?
    
    init(fromModel event: Event) {
        self.id = event.id
        self.title = event.title
        self.eventDescription = event.eventDescription
        self.date = event.date
        self.endDate = event.endDate
        self.location = event.location
        self.address = event.address
        self.isAllDay = event.isAllDay
        self.reminderMinutes = event.reminderMinutes
        self.createdAt = event.createdAt
        self.updatedAt = event.updatedAt
        self.scheduleId = event.schedule?.id
    }
    
    func toModel() -> Event {
        let event = Event(
            title: title,
            date: date,
            location: location,
            isAllDay: isAllDay
        )
        event.id = id
        event.eventDescription = eventDescription
        event.endDate = endDate
        event.address = address
        event.reminderMinutes = reminderMinutes
        event.createdAt = createdAt
        event.updatedAt = updatedAt
        return event
    }
}

// MARK: - Announcement DTO
struct AnnouncementDTO: Codable, Sendable {
    let id: UUID
    let title: String
    let content: String
    let priority: String
    let expiresAt: Date?
    let isPinned: Bool
    let attachmentURLs: [String]
    let createdAt: Date
    let updatedAt: Date
    let teamId: UUID?
    
    init(fromModel announcement: Announcement) {
        self.id = announcement.id
        self.title = announcement.title
        self.content = announcement.content
        self.priority = announcement.priority.rawValue
        self.expiresAt = announcement.expiresAt
        self.isPinned = announcement.isPinned
        self.attachmentURLs = announcement.attachmentURLs
        self.createdAt = announcement.createdAt
        self.updatedAt = announcement.updatedAt
        self.teamId = announcement.team?.id
    }
    
    func toModel() -> Announcement {
        let announcement = Announcement(
            title: title,
            content: content,
            priority: Announcement.Priority(rawValue: priority) ?? .normal,
            isPinned: isPinned
        )
        announcement.id = id
        announcement.expiresAt = expiresAt
        announcement.attachmentURLs = attachmentURLs
        announcement.createdAt = createdAt
        announcement.updatedAt = updatedAt
        return announcement
    }
}