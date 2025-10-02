//
//  Team.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import Foundation
import SwiftData

@Model
final class Team: @unchecked Sendable {
    var id: UUID
    var teamCode: String
    var name: String
    var ageGroup: String
    var coachName: String
    var coachRole: CoachRole
    var assistantCoaches: [String]
    var primaryColor: String
    var secondaryColor: String
    var logoURL: String?
    var practiceLocation: String?
    var practiceTime: String?
    var homeVenue: String?
    var seasonRecord: String?
    var wins: Int = 0
    var losses: Int = 0
    var organization: String?
    var season: String?
    var coachEmail: String?
    var coachPhone: String?
    var createdAt: Date
    var updatedAt: Date
    var isActive: Bool
    
    // Sync tracking
    var lastSyncedAt: Date?
    var syncVersion: Int = 1

    @Relationship(deleteRule: .cascade) var players: [Player]?
    @Relationship(deleteRule: .cascade) var schedules: [Schedule]?
    @Relationship(deleteRule: .cascade) var announcements: [Announcement]?

    init(
        name: String,
        teamCode: String,
        organization: String = "",
        ageGroup: String = "",
        season: String = ""
    ) {
        self.id = UUID()
        self.teamCode = teamCode.isEmpty ? Team.generateTeamCode() : teamCode
        self.name = name
        self.organization = organization
        self.ageGroup = ageGroup
        self.season = season
        self.coachName = ""
        self.coachRole = .headCoach
        self.coachEmail = nil
        self.coachPhone = nil
        self.assistantCoaches = []
        self.primaryColor = "#FF7113"
        self.secondaryColor = "#000000"
        self.practiceLocation = nil
        self.practiceTime = nil
        self.homeVenue = nil
        self.seasonRecord = "0-0"
        self.wins = 0
        self.losses = 0
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isActive = true
        self.lastSyncedAt = nil
        self.syncVersion = 1
    }

    static func generateTeamCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}

enum CoachRole: String, CaseIterable, Codable, Sendable {
    case headCoach = "Head Coach"
    case assistantCoach = "Assistant Coach"
    case director = "Director"

    var displayName: String {
        return self.rawValue
    }

    var canManageAllTeams: Bool {
        return self == .director
    }

    var canSendNotifications: Bool {
        return true
    }
}