//
//  ScheduleDetailView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI

struct ScheduleDetailView: View {
    let schedule: Schedule
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    private var isTournament: Bool {
        schedule.eventType == .tournament
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: schedule.date)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: schedule.date)
    }

    private var formattedArrivalTime: String? {
        guard let arrivalTime = schedule.arrivalTime else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: arrivalTime)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Event Header Card
                        VStack(spacing: 16) {
                            // Event Type Badge
                            HStack {
                                Text(schedule.eventType.rawValue.uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(eventTypeColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)

                                Spacer()

                                if schedule.isHome {
                                    Text("HOME")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.3))
                                        .foregroundColor(Color.green)
                                        .cornerRadius(4)
                                } else {
                                    Text("AWAY")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.3))
                                        .foregroundColor(Color.blue)
                                        .cornerRadius(4)
                                }
                            }

                            // Event Title
                            VStack(alignment: .leading, spacing: 8) {
                                if let opponent = schedule.opponent {
                                    Text("vs \(opponent)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                } else {
                                    Text(schedule.eventType.rawValue)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }

                                Text(schedule.location)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // Date and Time
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color("BasketballOrange"))
                                    Text(formattedDate)
                                        .foregroundColor(.white)
                                    Spacer()
                                }

                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(Color("BasketballOrange"))
                                    Text("Game Time: \(formattedTime)")
                                        .foregroundColor(.white)
                                    Spacer()
                                }

                                if let arrivalTime = formattedArrivalTime {
                                    HStack {
                                        Image(systemName: "figure.walk.arrival")
                                            .foregroundColor(Color("BasketballOrange"))
                                        Text("Arrival Time: \(arrivalTime)")
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                            }
                            .font(.subheadline)

                            // Result (if game is completed)
                            if let result = schedule.result,
                               let teamScore = schedule.teamScore,
                               let opponentScore = schedule.opponentScore {
                                HStack {
                                    resultBadge(for: result)
                                    Spacer()
                                    Text("\(teamScore) - \(opponentScore)")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .padding(.top, 8)
                            }

                            // Notes
                            if let notes = schedule.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                    Text(notes)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color("CardBackground"))
                        .cornerRadius(15)

                        // Venue Information
                        if let venue = schedule.venue {
                            VenueDetailSection(venue: venue)
                        }

                        // Hotel Information (for tournaments)
                        if isTournament, let hotel = schedule.hotel {
                            HotelInformationView(hotel: hotel, isPrimary: hotel.isOfficialHotel)
                        }

                        // Additional tournament info (airports)
                        if isTournament, let venue = schedule.venue {
                            if let airports = venue.nearbyAirports, !airports.isEmpty {
                                AirportInformationView(airports: Array(airports))
                            }
                        }

                        // Parking Information
                        if let venue = schedule.venue,
                           let parking = venue.parkingOptions,
                           !parking.isEmpty {
                            ParkingInformationView(parkingOptions: Array(parking))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("BasketballOrange"))
                }
            }
        }
    }

    private var eventTypeColor: Color {
        switch schedule.eventType {
        case .game:
            return Color("BasketballOrange")
        case .practice:
            return Color.blue
        case .tournament:
            return Color.purple
        case .scrimmage:
            return Color.green
        case .teamEvent:
            return Color.pink
        }
    }

    private func resultBadge(for result: Schedule.GameResult) -> some View {
        let config: (text: String, color: Color) = {
            switch result {
            case .win:
                return ("WIN", .green)
            case .loss:
                return ("LOSS", .red)
            case .tie:
                return ("TIE", .gray)
            }
        }()

        return Text(config.text)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(config.color.opacity(0.3))
            .foregroundColor(config.color)
            .cornerRadius(4)
    }
}