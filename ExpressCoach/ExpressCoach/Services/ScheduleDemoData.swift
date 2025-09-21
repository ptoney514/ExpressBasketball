//
//  ScheduleDemoData.swift
//  ExpressCoach
//
//  Demo data generator for the new Schedule timeline view
//

import Foundation
import SwiftData

extension Schedule {
    /// Creates demo schedule events for testing the timeline view
    static func createDemoEvents(for team: Team, in context: ModelContext) {
        let calendar = Calendar.current
        let today = Date()

        // Practice - Today at 4 PM
        let practice1 = Schedule(
            eventType: .practice,
            location: "Express Basketball Gym B",
            date: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: today) ?? today,
            isHome: true
        )
        practice1.notes = "Focus on defensive drills"
        practice1.team = team
        context.insert(practice1)

        // Game - Today at 7 PM (LIVE during current time)
        let game1 = Schedule(
            eventType: .game,
            location: "Homestead High School",
            date: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today) ?? today,
            isHome: false
        )
        game1.opponent = "Warriors U14"
        game1.notes = "Playoffs - Round 1"
        game1.team = team
        context.insert(game1)

        // Practice - Tomorrow at 9 AM
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let practice2 = Schedule(
            eventType: .practice,
            location: "Express Basketball Gym A",
            date: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) ?? tomorrow,
            isHome: true
        )
        practice2.notes = "Morning conditioning session"
        practice2.team = team
        context.insert(practice2)

        // Tournament - Tomorrow at 2 PM
        let tournament = Schedule(
            eventType: .tournament,
            location: "San Jose Convention Center",
            date: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: tomorrow) ?? tomorrow,
            isHome: false
        )
        tournament.opponent = "Bay Area Classic"
        tournament.notes = "Check-in at 1:30 PM"
        tournament.team = team
        context.insert(tournament)

        // Cancelled Practice - Day after tomorrow
        let dayAfter = calendar.date(byAdding: .day, value: 2, to: today) ?? today
        let cancelledPractice = Schedule(
            eventType: .practice,
            location: "Express Basketball Gym B",
            date: calendar.date(bySettingHour: 17, minute: 30, second: 0, of: dayAfter) ?? dayAfter,
            isHome: true
        )
        cancelledPractice.isCancelled = true
        cancelledPractice.notes = "Gym maintenance"
        cancelledPractice.team = team
        context.insert(cancelledPractice)

        // Game - In 3 days at 6 PM
        let threeDays = calendar.date(byAdding: .day, value: 3, to: today) ?? today
        let game2 = Schedule(
            eventType: .game,
            location: "Express Arena",
            date: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: threeDays) ?? threeDays,
            isHome: true
        )
        game2.opponent = "Lightning U14"
        game2.notes = "Senior night celebration"
        game2.team = team
        context.insert(game2)

        // Scrimmage - In 4 days at 10 AM
        let fourDays = calendar.date(byAdding: .day, value: 4, to: today) ?? today
        let scrimmage = Schedule(
            eventType: .scrimmage,
            location: "Palo Alto Community Center",
            date: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: fourDays) ?? fourDays,
            isHome: false
        )
        scrimmage.opponent = "Thunder Academy"
        scrimmage.notes = "Pre-tournament warmup"
        scrimmage.team = team
        context.insert(scrimmage)

        // Team Event - In 5 days at 12 PM
        let fiveDays = calendar.date(byAdding: .day, value: 5, to: today) ?? today
        let teamEvent = Schedule(
            eventType: .teamEvent,
            location: "Round Table Pizza",
            date: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: fiveDays) ?? fiveDays,
            isHome: false
        )
        teamEvent.notes = "Team bonding lunch"
        teamEvent.team = team
        context.insert(teamEvent)

        // Past game with result - Yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let pastGame = Schedule(
            eventType: .game,
            location: "Express Arena",
            date: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: yesterday) ?? yesterday,
            isHome: true
        )
        pastGame.opponent = "Rockets U14"
        pastGame.result = .win
        pastGame.teamScore = 65
        pastGame.opponentScore = 58
        pastGame.notes = "Great defensive effort"
        pastGame.team = team
        context.insert(pastGame)

        // Multiple events on same day (weekend tournament)
        let saturday = calendar.date(byAdding: .day, value: 6, to: today) ?? today

        // Morning game
        let saturdayGame1 = Schedule(
            eventType: .tournament,
            location: "Oakland Sports Complex",
            date: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: saturday) ?? saturday,
            isHome: false
        )
        saturdayGame1.opponent = "Tournament Pool Play"
        saturdayGame1.notes = "Game 1 vs. Mavericks"
        saturdayGame1.team = team
        context.insert(saturdayGame1)

        // Afternoon game
        let saturdayGame2 = Schedule(
            eventType: .tournament,
            location: "Oakland Sports Complex",
            date: calendar.date(bySettingHour: 14, minute: 30, second: 0, of: saturday) ?? saturday,
            isHome: false
        )
        saturdayGame2.opponent = "Tournament Pool Play"
        saturdayGame2.notes = "Game 2 vs. Spurs Academy"
        saturdayGame2.team = team
        context.insert(saturdayGame2)

        // Evening game
        let saturdayGame3 = Schedule(
            eventType: .tournament,
            location: "Oakland Sports Complex",
            date: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: saturday) ?? saturday,
            isHome: false
        )
        saturdayGame3.opponent = "Tournament Pool Play"
        saturdayGame3.notes = "Game 3 vs. Heat Elite"
        saturdayGame3.team = team
        context.insert(saturdayGame3)

        // Save all changes
        do {
            try context.save()
            print("Successfully created demo schedule events")
        } catch {
            print("Error saving demo schedule events: \(error)")
        }
    }
}