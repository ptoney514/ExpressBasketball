//
//  Player.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import Foundation
import SwiftData

@Model
final class Player {
    var id: UUID
    var firstName: String
    var lastName: String
    var jerseyNumber: String
    var position: String
    var dateOfBirth: Date?
    var height: String?
    var grade: String?
    var parentName: String?
    var parentEmail: String?
    var parentPhone: String?
    var emergencyContact: String?
    var emergencyPhone: String?
    var medicalNotes: String?
    var photoURL: String?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(inverse: \Team.players)
    var team: Team?

    init(
        firstName: String,
        lastName: String,
        jerseyNumber: String,
        position: String = "Guard"
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.jerseyNumber = jerseyNumber
        self.position = position
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var displayName: String {
        "\(firstName) \(lastName.prefix(1))."
    }
}