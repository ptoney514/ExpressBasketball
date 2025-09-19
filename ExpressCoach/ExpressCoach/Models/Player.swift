//
//  Player.swift
//  ExpressCoach
//
//  Created on 9/18/25.
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
    var height: String?
    var grade: String
    var birthDate: Date?
    var parentName: String
    var parentEmail: String
    var parentPhone: String
    var emergencyContact: String
    var emergencyPhone: String
    var medicalNotes: String?
    var photoURL: String?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(inverse: \Team.players) var teams: [Team]?

    init(
        firstName: String,
        lastName: String,
        jerseyNumber: String,
        position: String,
        grade: String,
        parentName: String,
        parentEmail: String,
        parentPhone: String,
        emergencyContact: String,
        emergencyPhone: String
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.jerseyNumber = jerseyNumber
        self.position = position
        self.grade = grade
        self.parentName = parentName
        self.parentEmail = parentEmail
        self.parentPhone = parentPhone
        self.emergencyContact = emergencyContact
        self.emergencyPhone = emergencyPhone
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}