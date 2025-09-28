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
            teamCode: "DEMO01",
            organization: "Express Basketball",
            ageGroup: "U12 Boys",
            season: "2025 Spring"
        )
        
        team.coachName = "John Smith"

        team.practiceLocation = "Express Basketball Gym A"
        team.practiceTime = "Tue/Thu 5:00-6:30 PM"
        team.homeVenue = "Express Arena"
        team.seasonRecord = "12-3"

        // Add players
        let players = [
            createPlayer(firstName: "Jordan", lastName: "Smith", jerseyNumber: "23", position: "Point Guard", graduationYear: 2030),
            createPlayer(firstName: "Marcus", lastName: "Johnson", jerseyNumber: "11", position: "Shooting Guard", graduationYear: 2030),
            createPlayer(firstName: "Tyler", lastName: "Williams", jerseyNumber: "5", position: "Small Forward", graduationYear: 2031),
            createPlayer(firstName: "Ethan", lastName: "Davis", jerseyNumber: "32", position: "Power Forward", graduationYear: 2030),
            createPlayer(firstName: "Noah", lastName: "Brown", jerseyNumber: "15", position: "Center", graduationYear: 2030),
            createPlayer(firstName: "Lucas", lastName: "Martinez", jerseyNumber: "7", position: "Guard", graduationYear: 2031),
            createPlayer(firstName: "Mason", lastName: "Garcia", jerseyNumber: "21", position: "Forward", graduationYear: 2031),
            createPlayer(firstName: "Jayden", lastName: "Rodriguez", jerseyNumber: "10", position: "Guard", graduationYear: 2030),
            createPlayer(firstName: "Aiden", lastName: "Lee", jerseyNumber: "14", position: "Forward", graduationYear: 2031),
            createPlayer(firstName: "Dylan", lastName: "Taylor", jerseyNumber: "3", position: "Guard", graduationYear: 2030)
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
            teamCode: "DEMO02",
            organization: "Express Basketball",
            ageGroup: "U14 Boys",
            season: "2025 Spring"
        )
        
        team.coachName = "Mike Johnson"

        team.practiceLocation = "Express Basketball Gym B"
        team.practiceTime = "Mon/Wed 6:30-8:00 PM"
        team.homeVenue = "Express Arena"
        team.seasonRecord = "15-2"

        // Add players
        let players = [
            createPlayer(firstName: "James", lastName: "Wilson", jerseyNumber: "1", position: "Point Guard", graduationYear: 2028),
            createPlayer(firstName: "Michael", lastName: "Anderson", jerseyNumber: "24", position: "Shooting Guard", graduationYear: 2028),
            createPlayer(firstName: "Chris", lastName: "Thompson", jerseyNumber: "12", position: "Small Forward", graduationYear: 2029),
            createPlayer(firstName: "Kevin", lastName: "White", jerseyNumber: "34", position: "Power Forward", graduationYear: 2028),
            createPlayer(firstName: "Brandon", lastName: "Harris", jerseyNumber: "45", position: "Center", graduationYear: 2028),
            createPlayer(firstName: "Ryan", lastName: "Clark", jerseyNumber: "8", position: "Guard", graduationYear: 2029),
            createPlayer(firstName: "Nathan", lastName: "Lewis", jerseyNumber: "22", position: "Forward", graduationYear: 2028),
            createPlayer(firstName: "Justin", lastName: "Walker", jerseyNumber: "13", position: "Guard", graduationYear: 2029),
            createPlayer(firstName: "Anthony", lastName: "Hall", jerseyNumber: "30", position: "Forward", graduationYear: 2028),
            createPlayer(firstName: "David", lastName: "Young", jerseyNumber: "9", position: "Guard", graduationYear: 2029),
            createPlayer(firstName: "Isaiah", lastName: "King", jerseyNumber: "6", position: "Forward", graduationYear: 2028),
            createPlayer(firstName: "Caleb", lastName: "Wright", jerseyNumber: "17", position: "Center", graduationYear: 2028)
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
        graduationYear: Int
    ) -> Player {
        let player = Player(
            firstName: firstName,
            lastName: lastName,
            jerseyNumber: jerseyNumber,
            position: position,
            graduationYear: graduationYear,
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

        // Create demo venues
        let venues = createDemoVenues()

        // Practice venue
        let practiceVenue = venues["practice"]!

        // Practice - every Tuesday and Thursday
        for weekOffset in 0..<4 {
            let weekDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: now)!

            // Tuesday practice
            if let tuesdayDate = getNextWeekday(2, from: weekDate) {
                let practice = Schedule(
                    eventType: .practice,
                    location: practiceVenue.name,
                    date: tuesdayDate
                )
                practice.venue = practiceVenue
                practice.notes = "Regular practice session. Bring water and proper gear."
                schedules.append(practice)
            }

            // Thursday practice
            if let thursdayDate = getNextWeekday(4, from: weekDate) {
                let practice = Schedule(
                    eventType: .practice,
                    location: practiceVenue.name,
                    date: thursdayDate
                )
                practice.venue = practiceVenue
                practice.notes = "Regular practice session. Focus on defensive drills."
                schedules.append(practice)
            }
        }

        // Games - upcoming Saturday games
        let gameOpponents = ["City Hawks", "Metro Eagles", "Valley Warriors", "Downtown Blazers"]
        let gameVenueKeys = ["home", "away1", "home", "away2"]
        let isHomeList = [true, false, true, false]

        for (index, opponent) in gameOpponents.enumerated() {
            if let gameDate = getNextWeekday(6, from: calendar.date(byAdding: .weekOfYear, value: index, to: now)!) {
                let venue = venues[gameVenueKeys[index]]!
                let game = Schedule(
                    eventType: .game,
                    location: venue.name,
                    date: gameDate,
                    isHome: isHomeList[index]
                )
                game.venue = venue
                game.opponent = opponent
                game.notes = index == 0 ? "Important league game. Arrive 30 minutes early for warm-up." : nil

                // Add arrival time for games
                game.arrivalTime = calendar.date(byAdding: .minute, value: -45, to: gameDate)

                schedules.append(game)
            }
        }

        // Tournament - in 3 weeks
        if let tournamentDate = calendar.date(byAdding: .weekOfYear, value: 3, to: now) {
            let tournamentVenue = venues["tournament"]!
            let tournamentHotel = createTournamentHotel()

            let tournament = Schedule(
                eventType: .tournament,
                location: tournamentVenue.name,
                date: tournamentDate
            )
            tournament.venue = tournamentVenue
            tournament.hotel = tournamentHotel
            tournament.notes = "Spring Championship Tournament. Pool play starts at 8 AM."
            tournament.arrivalTime = calendar.date(byAdding: .minute, value: -60, to: tournamentDate)
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

    private func createDemoVenues() -> [String: Venue] {
        var venues: [String: Venue] = [:]

        // Home Arena
        let homeArena = Venue(
            name: "Express Arena",
            streetAddress: "1234 Basketball Way",
            city: "Springfield",
            state: "IL",
            zipCode: "62701",
            latitude: 39.7817,
            longitude: -89.6501,
            phone: "555-0100",
            website: "https://expressarena.com",
            capacity: 2500,
            courtCount: 2,
            notes: "Main entrance on north side. Concessions available."
        )

        // Add parking options for home arena
        let homeVenueParking = ParkingOption(
            name: "Arena Main Lot",
            type: .venueParking,
            location: "North entrance",
            pricing: "$10 event parking",
            distanceFromVenue: 0.1,
            eventRate: 10,
            capacity: 500,
            isPreferred: true
        )

        let homeStreetParking = ParkingOption(
            name: "Basketball Way Street",
            type: .streetParking,
            location: "Along Basketball Way",
            pricing: "Free - 2 hour limit",
            distanceFromVenue: 0.2,
            dailyRate: 0,
            notes: "Limited availability on game days"
        )

        homeArena.parkingOptions = [homeVenueParking, homeStreetParking]
        venues["home"] = homeArena

        // Practice Facility
        let practiceGym = Venue(
            name: "Express Basketball Training Center",
            streetAddress: "500 Training Dr",
            city: "Springfield",
            state: "IL",
            zipCode: "62702",
            latitude: 39.7900,
            longitude: -89.6400,
            phone: "555-0101",
            courtCount: 3,
            notes: "Use side entrance for practices. Code: 1234"
        )

        let practiceParking = ParkingOption(
            name: "Training Center Lot",
            type: .venueParking,
            location: "Adjacent to building",
            pricing: "Free for team members",
            distanceFromVenue: 0,
            dailyRate: 0,
            isPreferred: true
        )

        practiceGym.parkingOptions = [practiceParking]
        venues["practice"] = practiceGym

        // Away Venue 1
        let awayVenue1 = Venue(
            name: "City Sports Complex",
            streetAddress: "789 Sports Plaza",
            city: "Capital City",
            state: "IL",
            zipCode: "62703",
            latitude: 39.8200,
            longitude: -89.6800,
            phone: "555-0200",
            capacity: 3000,
            courtCount: 4
        )

        let away1Parking = ParkingOption(
            name: "Sports Complex Garage",
            type: .publicGarage,
            location: "East side of complex",
            pricing: "$15 flat rate",
            distanceFromVenue: 0.3,
            eventRate: 15,
            capacity: 800
        )

        awayVenue1.parkingOptions = [away1Parking]
        venues["away1"] = awayVenue1

        // Away Venue 2
        let awayVenue2 = Venue(
            name: "Valley Court",
            streetAddress: "456 Valley Rd",
            city: "Valley Town",
            state: "IL",
            zipCode: "62704",
            latitude: 39.7500,
            longitude: -89.7000,
            phone: "555-0300",
            capacity: 1500,
            courtCount: 2
        )

        let away2Parking = ParkingOption(
            name: "Valley Court Lot",
            type: .venueParking,
            location: "Main entrance",
            pricing: "$8 event parking",
            distanceFromVenue: 0.1,
            eventRate: 8,
            capacity: 300
        )

        awayVenue2.parkingOptions = [away2Parking]
        venues["away2"] = awayVenue2

        // Tournament Venue
        let tournamentVenue = Venue(
            name: "Regional Sports Center",
            streetAddress: "2000 Championship Blvd",
            city: "Metro City",
            state: "IL",
            zipCode: "62705",
            latitude: 39.8500,
            longitude: -89.7500,
            phone: "555-0400",
            website: "https://regionalsportscenter.com",
            capacity: 5000,
            courtCount: 6,
            notes: "Multiple courts for tournament play. Check court assignments at registration."
        )

        // Tournament parking options
        let tournamentMainParking = ParkingOption(
            name: "Championship Lot A",
            type: .venueParking,
            location: "Main entrance off Championship Blvd",
            pricing: "$20 tournament pass",
            distanceFromVenue: 0.1,
            eventRate: 20,
            capacity: 1000,
            isPreferred: true,
            notes: "Tournament pass valid for all weekend"
        )

        let tournamentOverflow = ParkingOption(
            name: "Overflow Lot B",
            type: .privateLot,
            location: "Access from Stadium Dr",
            pricing: "$15 daily",
            distanceFromVenue: 0.5,
            dailyRate: 15,
            capacity: 500,
            notes: "Shuttle service available every 15 minutes"
        )

        tournamentVenue.parkingOptions = [tournamentMainParking, tournamentOverflow]

        // Add airports for tournament venue
        let primaryAirport = Airport(
            name: "Metro International Airport",
            code: "MIA",
            city: "Metro City",
            state: "IL",
            distanceFromVenue: 25,
            estimatedDriveTime: 35,
            publicTransitAvailable: true,
            publicTransitInstructions: "Take Blue Line to Sports Center Station (45 min, $5)",
            isPrimary: true
        )

        let alternateAirport = Airport(
            name: "Capital Regional Airport",
            code: "CRA",
            city: "Capital City",
            state: "IL",
            distanceFromVenue: 45,
            estimatedDriveTime: 55,
            publicTransitAvailable: false,
            isPrimary: false
        )

        tournamentVenue.nearbyAirports = [primaryAirport, alternateAirport]

        venues["tournament"] = tournamentVenue

        return venues
    }

    private func createTournamentHotel() -> Hotel {
        let hotel = Hotel(
            name: "Springfield Marriott Downtown",
            streetAddress: "100 Hotel Plaza",
            city: "Metro City",
            state: "IL",
            zipCode: "62706",
            phone: "555-0500",
            distanceFromVenue: 2.5,
            teamRate: 129,
            teamRateCode: "BBALL2025",
            bookingInstructions: "Mention 'Express Basketball Tournament' when booking. Rate available until 2 weeks before event.",
            amenities: ["Free WiFi", "Indoor Pool", "Fitness Center", "Complimentary Breakfast", "Shuttle Service"],
            isOfficialHotel: true
        )

        hotel.brandName = "Marriott"
        hotel.website = "https://marriott.com"
        hotel.checkInTime = "3:00 PM"
        hotel.checkOutTime = "11:00 AM"
        hotel.notes = "Shuttle runs every 30 minutes to tournament venue starting at 7 AM"

        return hotel
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

        // Delete venues
        let venues = try modelContext.fetch(FetchDescriptor<Venue>())
        for venue in venues {
            modelContext.delete(venue)
        }

        // Delete hotels
        let hotels = try modelContext.fetch(FetchDescriptor<Hotel>())
        for hotel in hotels {
            modelContext.delete(hotel)
        }

        // Delete airports
        let airports = try modelContext.fetch(FetchDescriptor<Airport>())
        for airport in airports {
            modelContext.delete(airport)
        }

        // Delete parking options
        let parkingOptions = try modelContext.fetch(FetchDescriptor<ParkingOption>())
        for parking in parkingOptions {
            modelContext.delete(parking)
        }

        try modelContext.save()
        print("All data cleared")
    }
}