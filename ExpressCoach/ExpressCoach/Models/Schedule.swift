//
//  Schedule.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import Foundation
import SwiftData

@Model
final class Schedule: @unchecked Sendable {
    var id: UUID
    var eventType: EventType
    var opponent: String?
    var location: String
    var address: String?
    var date: Date
    var arrivalTime: Date?
    var isHome: Bool
    var notes: String?
    var result: GameResult?
    var teamScore: Int?
    var opponentScore: Int?
    var isCancelled: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(inverse: \Team.schedules) var team: Team?
    @Relationship(deleteRule: .cascade) var events: [Event]?
    // Relationships with Venue and Hotel
    var venue: Venue?
    var hotel: Hotel?

    init(
        eventType: EventType,
        location: String,
        date: Date,
        isHome: Bool = true
    ) {
        self.id = UUID()
        self.eventType = eventType
        self.location = location
        self.date = date
        self.isHome = isHome
        self.isCancelled = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    enum EventType: String, CaseIterable, Codable, Sendable {
        case game = "Game"
        case practice = "Practice"
        case tournament = "Tournament"
        case scrimmage = "Scrimmage"
        case teamEvent = "Team Event"
    }

    enum GameResult: String, CaseIterable, Codable, Sendable {
        case win = "Win"
        case loss = "Loss"
        case tie = "Tie"
    }
}