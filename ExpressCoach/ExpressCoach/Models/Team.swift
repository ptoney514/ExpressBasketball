//
//  Team.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import Foundation
import SwiftData

@Model
final class Team {
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
    var createdAt: Date
    var updatedAt: Date
    var isActive: Bool

    @Relationship(deleteRule: .cascade) var players: [Player]?
    @Relationship(deleteRule: .cascade) var schedules: [Schedule]?
    @Relationship(deleteRule: .cascade) var announcements: [Announcement]?

    init(
        name: String,
        ageGroup: String,
        coachName: String,
        coachRole: CoachRole = .headCoach,
        primaryColor: String = "#FF7113",
        secondaryColor: String = "#000000"
    ) {
        self.id = UUID()
        self.teamCode = Team.generateTeamCode()
        self.name = name
        self.ageGroup = ageGroup
        self.coachName = coachName
        self.coachRole = coachRole
        self.assistantCoaches = []
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.practiceLocation = nil
        self.practiceTime = nil
        self.homeVenue = nil
        self.seasonRecord = "0-0"
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isActive = true
    }

    static func generateTeamCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}

enum CoachRole: String, CaseIterable, Codable {
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