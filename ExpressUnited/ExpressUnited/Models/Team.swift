//
//  Team.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import Foundation
import SwiftData

@Model
final class Team {
    var id: UUID
    var name: String
    var ageGroup: String
    var season: String
    var teamCode: String
    var primaryColor: String
    var secondaryColor: String
    var coachName: String?
    var assistantCoachName: String?
    var managerName: String?
    var practiceLocation: String?
    var homeVenue: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade)
    var players: [Player]

    @Relationship(deleteRule: .cascade)
    var schedules: [Schedule]

    @Relationship(deleteRule: .cascade)
    var announcements: [Announcement]

    init(
        name: String,
        ageGroup: String,
        season: String = "2024-2025",
        teamCode: String,
        primaryColor: String = "#FF6B35",
        secondaryColor: String = "#2C3E50"
    ) {
        self.id = UUID()
        self.name = name
        self.ageGroup = ageGroup
        self.season = season
        self.teamCode = teamCode
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.players = []
        self.schedules = []
        self.announcements = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}