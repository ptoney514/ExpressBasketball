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
    var assistantCoaches: [String]
    var primaryColor: String
    var secondaryColor: String
    var logoURL: String?
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
        primaryColor: String = "#000000",
        secondaryColor: String = "#FFFFFF"
    ) {
        self.id = UUID()
        self.teamCode = Team.generateTeamCode()
        self.name = name
        self.ageGroup = ageGroup
        self.coachName = coachName
        self.assistantCoaches = []
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isActive = true
    }

    static func generateTeamCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}