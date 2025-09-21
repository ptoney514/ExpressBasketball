//
//  ParkingInformationView.swift
//  ExpressCoach
//
//  Created on 9/21/25.
//

import SwiftUI

struct ParkingInformationView: View {
    let parkingOptions: [ParkingOption]

    var preferredParking: [ParkingOption] {
        parkingOptions.filter { $0.isPreferred }.sorted { ($0.distanceFromVenue ?? 0) < ($1.distanceFromVenue ?? 0) }
    }

    var alternativeParking: [ParkingOption] {
        parkingOptions.filter { !$0.isPreferred }.sorted { ($0.distanceFromVenue ?? 0) < ($1.distanceFromVenue ?? 0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(Color("BasketballOrange"))
                    .font(.system(size: 20))

                Text("Parking Information")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()
            }

            // Parking Card
            VStack(alignment: .leading, spacing: 16) {
                // Preferred/Venue Parking
                if !preferredParking.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Venue Parking")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Spacer()

                            Text("RECOMMENDED")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color("BasketballOrange").opacity(0.3))
                                .foregroundColor(Color("BasketballOrange"))
                                .cornerRadius(4)
                        }

                        ForEach(preferredParking) { parking in
                            ParkingOptionRow(parking: parking, isPreferred: true)
                            if parking.id != preferredParking.last?.id {
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                            }
                        }
                    }
                }

                // Alternative Parking
                if !alternativeParking.isEmpty {
                    if !preferredParking.isEmpty {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Alternative Parking")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        ForEach(alternativeParking) { parking in
                            ParkingOptionRow(parking: parking, isPreferred: false)
                            if parking.id != alternativeParking.last?.id {
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                            }
                        }
                    }
                }

                // Parking Tips
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .background(Color.gray.opacity(0.3))

                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color("BasketballOrange"))
                            .font(.system(size: 14))

                        Text("Parking Tips")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        if parkingOptions.contains(where: { $0.type == .streetParking }) {
                            Text("• Street parking may have time restrictions")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Text("• Arrive early for tournament games")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("• Consider carpooling with other families")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(15)
        }
    }
}

struct ParkingOptionRow: View {
    let parking: ParkingOption
    let isPreferred: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Parking Name and Type
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(parking.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isPreferred ? Color("BasketballOrange") : .white)

                    HStack(spacing: 8) {
                        Label(parking.type.rawValue, systemImage: parkingTypeIcon)
                            .font(.caption)
                            .foregroundColor(.gray)

                        if let capacity = parking.capacity {
                            Text("• \(capacity) spaces")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Spacer()

                // Price Badge
                if let eventRate = parking.eventRate {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "$%.0f", eventRate))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("event")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else if let dailyRate = parking.dailyRate {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "$%.0f", dailyRate))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("daily")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else if parking.pricing.lowercased().contains("free") {
                    Text("FREE")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                }
            }

            // Location and Distance
            HStack(spacing: 16) {
                if !parking.location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(parking.location)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }

                if let distance = parking.distanceFromVenue {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(formatDistance(distance))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            // Additional pricing info
            if !parking.pricing.isEmpty && !parking.pricing.lowercased().contains("free") {
                Text(parking.pricing)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
            }

            // Notes
            if let notes = parking.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var parkingTypeIcon: String {
        switch parking.type {
        case .venueParking:
            return "building.2.fill"
        case .streetParking:
            return "road.lanes"
        case .publicGarage:
            return "square.stack.3d.up.fill"
        case .privateLot:
            return "rectangle.fill"
        case .valet:
            return "person.fill"
        }
    }

    private func formatDistance(_ distance: Double) -> String {
        if distance < 0.25 {
            return "< 5 min walk"
        } else if distance < 0.5 {
            return "5-10 min walk"
        } else if distance < 1.0 {
            return String(format: "%.1f mile", distance)
        } else {
            return String(format: "%.0f blocks", distance * 10)
        }
    }
}