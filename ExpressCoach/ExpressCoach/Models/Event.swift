//
//  Event.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import Foundation
import SwiftData

@Model
final class Event {
    var id: UUID
    var title: String
    var eventDescription: String?
    var date: Date
    var endDate: Date?
    var location: String?
    var address: String?
    var isAllDay: Bool
    var reminderMinutes: Int?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(inverse: \Schedule.events) var schedule: Schedule?

    init(
        title: String,
        date: Date,
        location: String? = nil,
        isAllDay: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.location = location
        self.isAllDay = isAllDay
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}