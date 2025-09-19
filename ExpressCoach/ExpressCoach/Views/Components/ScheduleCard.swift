//
//  ScheduleCard.swift
//  ExpressCoach
//
//  Created on 9/19/25.
//

import SwiftUI
import SwiftData

struct ScheduleCard: View {
    let schedule: Schedule
    var isCompact: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Event type icon
            ZStack {
                Circle()
                    .fill(eventTypeColor)
                    .frame(width: isCompact ? 40 : 50, height: isCompact ? 40 : 50)

                Image(systemName: eventTypeIcon)
                    .font(isCompact ? .title3 : .title2)
                    .foregroundColor(.black)
            }

            // Event details
            VStack(alignment: .leading, spacing: isCompact ? 2 : 4) {
                HStack {
                    Text(schedule.eventType.rawValue)
                        .font(isCompact ? .subheadline : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if schedule.isCancelled {
                        Text("CANCELLED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                    }

                    Spacer()

                    if let result = schedule.result, let teamScore = schedule.teamScore, let opponentScore = schedule.opponentScore {
                        ScoreChip(result: result, teamScore: teamScore, opponentScore: opponentScore)
                    }
                }

                if let opponent = schedule.opponent, !opponent.isEmpty {
                    HStack(spacing: 4) {
                        Text("vs")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(opponent)
                            .font(isCompact ? .caption : .subheadline)
                            .foregroundColor(Color("BasketballOrange"))
                            .fontWeight(.medium)
                    }
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(Color("BasketballOrange"))
                        Text(schedule.location)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: schedule.isHome ? "house.fill" : "car.fill")
                            .font(.caption)
                            .foregroundColor(schedule.isHome ? Color("CourtGreen") : Color("BasketballOrange"))
                        Text(schedule.isHome ? "Home" : "Away")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                if !isCompact {
                    Text(formatDateTime(schedule.date))
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .fontWeight(.medium)

                    if let arrivalTime = schedule.arrivalTime {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(Color("BasketballOrange"))
                            Text("Arrive by \(formatTime(arrivalTime))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    if let notes = schedule.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                } else {
                    Text(formatDateTime(schedule.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            if !isCompact {
                VStack(spacing: 4) {
                    Text(formatDate(schedule.date))
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(formatTime(schedule.date))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(isCompact ? 12 : 16)
        .background(Color("BackgroundDark"))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(schedule.isCancelled ? Color.red.opacity(0.5) : eventTypeColor.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(8)
        .opacity(schedule.isCancelled ? 0.7 : 1.0)
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

    private var eventTypeIcon: String {
        switch schedule.eventType {
        case .game, .tournament:
            return "sportscourt.fill"
        case .practice:
            return "figure.basketball"
        case .scrimmage:
            return "figure.2.and.child.holdinghands"
        case .teamEvent:
            return "party.popper.fill"
        }
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ScoreChip: View {
    let result: Schedule.GameResult
    let teamScore: Int
    let opponentScore: Int

    var body: some View {
        HStack(spacing: 2) {
            Text("\(teamScore)-\(opponentScore)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(result.rawValue.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(resultColor)
                .cornerRadius(3)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color("CoachBlack"))
        .cornerRadius(6)
    }

    private var resultColor: Color {
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

#Preview {
    VStack(spacing: 12) {
        ScheduleCard(schedule: {
            let schedule = Schedule(
                eventType: .game,
                location: "Lincoln High School",
                date: Date().addingTimeInterval(86400), // Tomorrow
                isHome: false
            )
            schedule.opponent = "Warriors U14"
            schedule.arrivalTime = Date().addingTimeInterval(85800) // 30 min earlier
            schedule.notes = "Bring extra water bottles and team snacks"
            return schedule
        }(), isCompact: false)

        ScheduleCard(schedule: {
            let schedule = Schedule(
                eventType: .game,
                location: "Home Gym",
                date: Date().addingTimeInterval(-86400), // Yesterday
                isHome: true
            )
            schedule.opponent = "Lakers U14"
            schedule.result = .win
            schedule.teamScore = 65
            schedule.opponentScore = 58
            return schedule
        }(), isCompact: false)

        ScheduleCard(schedule: {
            let schedule = Schedule(
                eventType: .game,
                location: "Lincoln High School",
                date: Date().addingTimeInterval(86400), // Tomorrow
                isHome: false
            )
            schedule.opponent = "Warriors U14"
            schedule.arrivalTime = Date().addingTimeInterval(85800) // 30 min earlier
            schedule.notes = "Bring extra water bottles and team snacks"
            return schedule
        }(), isCompact: true)
    }
    .preferredColorScheme(.dark)
    .padding()
}