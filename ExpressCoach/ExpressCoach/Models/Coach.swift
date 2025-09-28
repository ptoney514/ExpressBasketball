//
//  Coach.swift
//  ExpressCoach
//
//  Model for authenticated coaches
//

import Foundation
import SwiftData

@Model
final class Coach {
    var id: UUID
    var userId: String // Supabase auth user ID
    var email: String
    var fullName: String
    var phone: String?
    var role: CoachRole
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // Sync tracking
    var lastSyncedAt: Date?
    var syncVersion: Int = 1
    
    // Relationships
    @Relationship var teams: [Team]?
    
    init(
        userId: String,
        email: String,
        fullName: String,
        phone: String? = nil,
        role: CoachRole = .headCoach
    ) {
        self.id = UUID()
        self.userId = userId
        self.email = email
        self.fullName = fullName
        self.phone = phone
        self.role = role
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastSyncedAt = nil
        self.syncVersion = 1
    }
}