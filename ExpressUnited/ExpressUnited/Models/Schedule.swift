//
//  Schedule.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import Foundation
import SwiftData

@Model
final class Schedule {
    var id: UUID
    var eventType: EventType
    var opponent: String?
    var location: String
    var startTime: Date
    var endTime: Date?
    var isHomeGame: Bool
    var notes: String?
    var result: String?
    var teamScore: Int?
    var opponentScore: Int?
    var isCancelled: Bool
    var cancellationReason: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(inverse: \Team.schedules)
    var team: Team?

    init(
        eventType: EventType,
        location: String,
        startTime: Date,
        endTime: Date? = nil,
        opponent: String? = nil,
        isHomeGame: Bool = true
    ) {
        self.id = UUID()
        self.eventType = eventType
        self.location = location
        self.startTime = startTime
        self.endTime = endTime ?? startTime.addingTimeInterval(7200)
        self.opponent = opponent
        self.isHomeGame = isHomeGame
        self.isCancelled = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum EventType: String, Codable, CaseIterable {
    case practice = "Practice"
    case game = "Game"
    case tournament = "Tournament"
    case scrimmage = "Scrimmage"
    case teamEvent = "Team Event"
    case meeting = "Meeting"

    var icon: String {
        switch self {
        case .practice: return "figure.basketball"
        case .game: return "sportscourt"
        case .tournament: return "trophy"
        case .scrimmage: return "figure.2.arms.open"
        case .teamEvent: return "person.3"
        case .meeting: return "bubble.left.and.bubble.right"
        }
    }

    var color: String {
        switch self {
        case .practice: return "blue"
        case .game: return "orange"
        case .tournament: return "purple"
        case .scrimmage: return "green"
        case .teamEvent: return "pink"
        case .meeting: return "gray"
        }
    }
}