//
//  DemoDataManager.swift
//  ExpressCoach
//
//  Manages demo data for offline/demo mode
//

import Foundation
import SwiftData

@MainActor
class DemoDataManager {
    static let shared = DemoDataManager()

    private init() {}

    func isDemoMode() -> Bool {
        return UserDefaults.standard.bool(forKey: "isDemoMode")
    }

    func setDemoMode(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "isDemoMode")
    }

    func seedDemoData(in modelContext: ModelContext) throws {
        // Check if demo data already exists
        let descriptor = FetchDescriptor<Team>(
            predicate: #Predicate { team in
                team.teamCode == "DEMO01" || team.teamCode == "DEMO02"
            }
        )

        let existingDemoTeams = try modelContext.fetch(descriptor)
        if !existingDemoTeams.isEmpty {
            print("Demo data already exists, skipping seed")
            return
        }

        // Create demo teams
        let thunderU12 = createThunderU12Team()
        let thunderU14 = createThunderU14Team()

        // Insert teams
        modelContext.insert(thunderU12)
        modelContext.insert(thunderU14)

        // Save context
        try modelContext.save()
        print("Demo data seeded successfully")
    }

    private func createThunderU12Team() -> Team {
        let team = Team(
            name: "Express Thunder",
            ageGroup: "U12 Boys",
            coachName: "John Smith"
        )

        team.teamCode = "DEMO01"

        team.practiceLocation = "Express Basketball Gym A"
        team.practiceTime = "Tue/Thu 5:00-6:30 PM"
        team.homeVenue = "Express Arena"
        team.seasonRecord = "12-3"

        // Add players
        let players = [
            createPlayer(firstName: "Jordan", lastName: "Smith", jerseyNumber: "23", position: "Point Guard", grade: "6th"),
            createPlayer(firstName: "Marcus", lastName: "Johnson", jerseyNumber: "11", position: "Shooting Guard", grade: "6th"),
            createPlayer(firstName: "Tyler", lastName: "Williams", jerseyNumber: "5", position: "Small Forward", grade: "5th"),
            createPlayer(firstName: "Ethan", lastName: "Davis", jerseyNumber: "32", position: "Power Forward", grade: "6th"),
            createPlayer(firstName: "Noah", lastName: "Brown", jerseyNumber: "15", position: "Center", grade: "6th"),
            createPlayer(firstName: "Lucas", lastName: "Martinez", jerseyNumber: "7", position: "Guard", grade: "5th"),
            createPlayer(firstName: "Mason", lastName: "Garcia", jerseyNumber: "21", position: "Forward", grade: "5th"),
            createPlayer(firstName: "Jayden", lastName: "Rodriguez", jerseyNumber: "10", position: "Guard", grade: "6th"),
            createPlayer(firstName: "Aiden", lastName: "Lee", jerseyNumber: "14", position: "Forward", grade: "5th"),
            createPlayer(firstName: "Dylan", lastName: "Taylor", jerseyNumber: "3", position: "Guard", grade: "6th")
        ]

        team.players = players

        // Add schedule items
        let schedules = createDemoSchedules(for: team)
        team.schedules = schedules

        // Add announcements
        let announcements = createDemoAnnouncements(for: team)
        team.announcements = announcements

        return team
    }

    private func createThunderU14Team() -> Team {
        let team = Team(
            name: "Express Lightning",
            ageGroup: "U14 Boys",
            coachName: "Mike Johnson"
        )

        team.teamCode = "DEMO02"

        team.practiceLocation = "Express Basketball Gym B"
        team.practiceTime = "Mon/Wed 6:30-8:00 PM"
        team.homeVenue = "Express Arena"
        team.seasonRecord = "15-2"

        // Add players
        let players = [
            createPlayer(firstName: "James", lastName: "Wilson", jerseyNumber: "1", position: "Point Guard", grade: "8th"),
            createPlayer(firstName: "Michael", lastName: "Anderson", jerseyNumber: "24", position: "Shooting Guard", grade: "8th"),
            createPlayer(firstName: "Chris", lastName: "Thompson", jerseyNumber: "12", position: "Small Forward", grade: "7th"),
            createPlayer(firstName: "Kevin", lastName: "White", jerseyNumber: "34", position: "Power Forward", grade: "8th"),
            createPlayer(firstName: "Brandon", lastName: "Harris", jerseyNumber: "45", position: "Center", grade: "8th"),
            createPlayer(firstName: "Ryan", lastName: "Clark", jerseyNumber: "8", position: "Guard", grade: "7th"),
            createPlayer(firstName: "Nathan", lastName: "Lewis", jerseyNumber: "22", position: "Forward", grade: "8th"),
            createPlayer(firstName: "Justin", lastName: "Walker", jerseyNumber: "13", position: "Guard", grade: "7th"),
            createPlayer(firstName: "Anthony", lastName: "Hall", jerseyNumber: "30", position: "Forward", grade: "8th"),
            createPlayer(firstName: "David", lastName: "Young", jerseyNumber: "9", position: "Guard", grade: "7th"),
            createPlayer(firstName: "Isaiah", lastName: "King", jerseyNumber: "6", position: "Forward", grade: "8th"),
            createPlayer(firstName: "Caleb", lastName: "Wright", jerseyNumber: "17", position: "Center", grade: "8th")
        ]

        team.players = players

        // Add schedule items
        let schedules = createDemoSchedules(for: team)
        team.schedules = schedules

        // Add announcements
        let announcements = createDemoAnnouncements(for: team)
        team.announcements = announcements

        return team
    }

    private func createPlayer(
        firstName: String,
        lastName: String,
        jerseyNumber: String,
        position: String,
        grade: String
    ) -> Player {
        let player = Player(
            firstName: firstName,
            lastName: lastName,
            jerseyNumber: jerseyNumber,
            position: position,
            grade: grade,
            parentName: "\(firstName)'s Parent",
            parentEmail: "\(firstName.lowercased()).parent@demo.com",
            parentPhone: "555-0\(String(format: "%03d", Int.random(in: 100...999)))",
            emergencyContact: "Emergency Contact",
            emergencyPhone: "555-9\(String(format: "%03d", Int.random(in: 100...999)))"
        )

        return player
    }

    private func createDemoSchedules(for team: Team) -> [Schedule] {
        let calendar = Calendar.current
        let now = Date()
        var schedules: [Schedule] = []

        // Practice - every Tuesday and Thursday
        for weekOffset in 0..<4 {
            let weekDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: now)!

            // Tuesday practice
            if let tuesdayDate = getNextWeekday(2, from: weekDate) {
                let practice = Schedule(
                    eventType: .practice,
                    location: team.practiceLocation ?? "Express Basketball Gym",
                    date: tuesdayDate
                )
                practice.notes = "Regular practice session. Bring water and proper gear."
                schedules.append(practice)
            }

            // Thursday practice
            if let thursdayDate = getNextWeekday(4, from: weekDate) {
                let practice = Schedule(
                    eventType: .practice,
                    location: team.practiceLocation ?? "Express Basketball Gym",
                    date: thursdayDate
                )
                practice.notes = "Regular practice session. Focus on defensive drills."
                schedules.append(practice)
            }
        }

        // Games - upcoming Saturday games
        let gameOpponents = ["City Hawks", "Metro Eagles", "Valley Warriors", "Downtown Blazers"]
        let gameVenues = ["Express Arena", "City Sports Complex", "Express Arena", "Valley Court"]
        let isHomeList = [true, false, true, false]

        for (index, opponent) in gameOpponents.enumerated() {
            if let gameDate = getNextWeekday(6, from: calendar.date(byAdding: .weekOfYear, value: index, to: now)!) {
                let game = Schedule(
                    eventType: .game,
                    location: gameVenues[index],
                    date: gameDate,
                    isHome: isHomeList[index]
                )
                game.opponent = opponent
                game.notes = index == 0 ? "Important league game. Arrive 30 minutes early for warm-up." : nil
                schedules.append(game)
            }
        }

        // Tournament - in 3 weeks
        if let tournamentDate = calendar.date(byAdding: .weekOfYear, value: 3, to: now) {
            let tournament = Schedule(
                eventType: .tournament,
                location: "Regional Sports Center",
                date: tournamentDate
            )
            tournament.notes = "Spring Championship Tournament. Pool play starts at 8 AM."
            schedules.append(tournament)
        }

        // Team event - pizza party
        if let eventDate = calendar.date(byAdding: .weekOfYear, value: 2, to: now) {
            let teamEvent = Schedule(
                eventType: .teamEvent,
                location: "Pizza Palace - Main Street",
                date: eventDate
            )
            teamEvent.notes = "End of season celebration! All players and families invited."
            schedules.append(teamEvent)
        }

        return schedules
    }

    private func createDemoAnnouncements(for team: Team) -> [Announcement] {
        let now = Date()
        var announcements: [Announcement] = []

        // Recent announcements
        let announcement1 = Announcement(
            title: "Practice Schedule Change",
            content: "Next Tuesday's practice moved to 6:00 PM due to gym availability. Please arrive on time.",
            priority: .high
        )
        announcement1.createdAt = Calendar.current.date(byAdding: .hour, value: -2, to: now)!
        announcements.append(announcement1)

        let announcement2 = Announcement(
            title: "Tournament Registration",
            content: "Spring Championship Tournament registration is now open! We're registered for the U12/U14 divisions. Tournament date is in 3 weeks. More details to follow.",
            priority: .normal
        )
        announcement2.createdAt = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        announcements.append(announcement2)

        let announcement3 = Announcement(
            title: "Uniform Reminder",
            content: "Please ensure all players have both home (white) and away (blue) jerseys for this weekend's games.",
            priority: .low
        )
        announcement3.createdAt = Calendar.current.date(byAdding: .day, value: -2, to: now)!
        announcements.append(announcement3)

        let announcement4 = Announcement(
            title: "Great Win Yesterday!",
            content: "Congratulations on the fantastic 68-55 victory! Great teamwork and effort from everyone. Keep up the excellent work!",
            priority: .low
        )
        announcement4.createdAt = Calendar.current.date(byAdding: .day, value: -3, to: now)!
        announcements.append(announcement4)

        return announcements
    }

    private func getNextWeekday(_ weekday: Int, from date: Date) -> Date? {
        let calendar = Calendar.current
        let components = DateComponents(weekday: weekday)
        return calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
    }

    func clearAllData(in modelContext: ModelContext) throws {
        // Delete all teams (cascades to related data)
        let teams = try modelContext.fetch(FetchDescriptor<Team>())
        for team in teams {
            modelContext.delete(team)
        }

        // Delete any orphaned players
        let players = try modelContext.fetch(FetchDescriptor<Player>())
        for player in players {
            modelContext.delete(player)
        }

        // Delete any orphaned schedules
        let schedules = try modelContext.fetch(FetchDescriptor<Schedule>())
        for schedule in schedules {
            modelContext.delete(schedule)
        }

        // Delete any orphaned announcements
        let announcements = try modelContext.fetch(FetchDescriptor<Announcement>())
        for announcement in announcements {
            modelContext.delete(announcement)
        }

        try modelContext.save()
        print("All data cleared")
    }
}