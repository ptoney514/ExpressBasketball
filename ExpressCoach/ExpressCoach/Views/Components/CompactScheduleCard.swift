//
//  CompactScheduleCard.swift
//  ExpressCoach
//
//  A condensed event card design for the schedule view
//

import SwiftUI
import SwiftData

struct CompactScheduleCard: View {
    let schedule: Schedule

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Time or status indicator on the left
            VStack(alignment: .leading, spacing: 2) {
                if schedule.date > Date() || Calendar.current.isDateInToday(schedule.date) {
                    Text(timeFormatter.string(from: schedule.date))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                } else if let result = schedule.result,
                          let teamScore = schedule.teamScore,
                          let opponentScore = schedule.opponentScore {
                    // Show score for past games
                    Text("\(teamScore)-\(opponentScore)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(resultColor(for: result))
                } else {
                    Text("TBD")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Text(eventTypeLabel)
                    .font(.caption)
                    .foregroundColor(eventTypeColor)
                    .textCase(.uppercase)
            }
            .frame(width: 65, alignment: .leading)

            // Main content
            VStack(alignment: .leading, spacing: 4) {
                // Title line with event type and opponent/description
                HStack {
                    if let opponent = schedule.opponent, !opponent.isEmpty {
                        Text("\(schedule.eventType.rawValue): \(opponent)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    } else {
                        Text(schedule.eventType.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Home/Away indicator for games
                    if schedule.eventType == .game || schedule.eventType == .scrimmage {
                        Image(systemName: schedule.isHome ? "house.fill" : "arrow.right.circle.fill")
                            .font(.caption)
                            .foregroundColor(schedule.isHome ? Color("CourtGreen") : Color("BasketballOrange"))
                    }
                }

                // Location and additional details
                HStack(spacing: 8) {
                    Text(schedule.location)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)

                    if schedule.isCancelled {
                        Text("• CANCELLED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }

                // Notes if present and important
                if let notes = schedule.notes, !notes.isEmpty, schedule.date > Date() {
                    Text(notes)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .padding(.top, 2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("CoachBlack"))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 1)
        )
        .opacity(schedule.isCancelled ? 0.6 : 1.0)
    }

    private var eventTypeLabel: String {
        switch schedule.eventType {
        case .game:
            return schedule.isHome ? "HOME" : "AWAY"
        case .practice:
            return "PRACTICE"
        case .tournament:
            return "TOURNEY"
        case .scrimmage:
            return "SCRIMMAGE"
        case .teamEvent:
            return "EVENT"
        }
    }

    private var eventTypeColor: Color {
        switch schedule.eventType {
        case .game, .tournament:
            return Color("BasketballOrange")
        case .practice:
            return Color("CourtGreen")
        case .scrimmage:
            return Color.blue
        case .teamEvent:
            return Color.purple
        }
    }

    private var borderColor: Color {
        if schedule.isCancelled {
            return Color.red.opacity(0.3)
        }

        switch schedule.eventType {
        case .game, .tournament:
            return Color("BasketballOrange").opacity(0.2)
        case .practice:
            return Color("CourtGreen").opacity(0.2)
        case .scrimmage:
            return Color.blue.opacity(0.2)
        case .teamEvent:
            return Color.purple.opacity(0.2)
        }
    }

    private func resultColor(for result: Schedule.GameResult) -> Color {
        switch result {
        case .win:
            return Color("CourtGreen")
        case .loss:
            return Color.red
        case .tie:
            return Color("BasketballOrange")
        }
    }
}

// Preview
#Preview {
    VStack(spacing: 12) {
        // Upcoming practice
        CompactScheduleCard(schedule: {
            let schedule = Schedule(
                eventType: .practice,
                location: "Express Basketball Gym B",
                date: Date().addingTimeInterval(86400), // Tomorrow
                isHome: true
            )
            return schedule
        }())

        // Upcoming game
        CompactScheduleCard(schedule: {
            let schedule = Schedule(
                eventType: .game,
                location: "Homestead High School - Back Gym",
                date: Date().addingTimeInterval(172800), // In 2 days
                isHome: false
            )
            schedule.opponent = "Shooting Stars"
            return schedule
        }())

        // Past game with score
        CompactScheduleCard(schedule: {
            let schedule = Schedule(
                eventType: .game,
                location: "Express Arena",
                date: Date().addingTimeInterval(-86400), // Yesterday
                isHome: true
            )
            schedule.opponent = "Lakers U14"
            schedule.result = .win
            schedule.teamScore = 65
            schedule.opponentScore = 58
            return schedule
        }())

        // Cancelled event
        CompactScheduleCard(schedule: {
            let schedule = Schedule(
                eventType: .practice,
                location: "Express Basketball Gym A",
                date: Date().addingTimeInterval(259200), // In 3 days
                isHome: true
            )
            schedule.isCancelled = true
            return schedule
        }())
    }
    .padding()
    .background(Color("BackgroundDark"))
    .preferredColorScheme(.dark)
}