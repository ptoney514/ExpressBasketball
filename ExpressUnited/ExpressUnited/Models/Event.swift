//
//  Event.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import Foundation
import SwiftData

@Model
final class Event {
    var id: UUID
    var title: String
    var eventDescription: String?
    var eventType: String
    var startDate: Date
    var endDate: Date?
    var location: String?
    var isAllDay: Bool
    var reminder: TimeInterval?
    var teamId: UUID?
    var createdAt: Date
    var updatedAt: Date

    init(
        title: String,
        eventType: String = "General",
        startDate: Date,
        location: String? = nil,
        isAllDay: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.eventType = eventType
        self.startDate = startDate
        self.endDate = startDate.addingTimeInterval(3600)
        self.location = location
        self.isAllDay = isAllDay
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}