//
//  Announcement.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import Foundation
import SwiftData

@Model
final class Announcement: @unchecked Sendable {
    var id: UUID
    var title: String
    var content: String
    var priority: Priority
    var expiresAt: Date?
    var isPinned: Bool
    var attachmentURLs: [String]
    var createdAt: Date
    var updatedAt: Date

    @Relationship(inverse: \Team.announcements) var team: Team?

    init(
        title: String,
        content: String,
        priority: Priority = .normal,
        isPinned: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.priority = priority
        self.isPinned = isPinned
        self.attachmentURLs = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    enum Priority: String, CaseIterable, Codable, Sendable {
        case low = "Low"
        case normal = "Normal"
        case high = "High"
        case urgent = "Urgent"
    }
}