//
//  AirportInformationView.swift
//  ExpressCoach
//
//  Created on 9/21/25.
//

import SwiftUI

struct AirportInformationView: View {
    let airports: [Airport]

    var primaryAirport: Airport? {
        airports.first(where: { $0.isPrimary })
    }

    var alternateAirports: [Airport] {
        airports.filter { !$0.isPrimary }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "airplane")
                    .foregroundColor(Color("BasketballOrange"))
                    .font(.system(size: 20))

                Text("Airport Information")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()
            }

            // Airports Card
            VStack(alignment: .leading, spacing: 16) {
                // Primary Airport
                if let primary = primaryAirport {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Primary Airport")
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

                        AirportRow(airport: primary, isPrimary: true)
                    }
                }

                // Alternate Airports
                if !alternateAirports.isEmpty {
                    if primaryAirport != nil {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Alternate Airports")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        ForEach(alternateAirports) { airport in
                            AirportRow(airport: airport, isPrimary: false)
                            if airport.id != alternateAirports.last?.id {
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                            }
                        }
                    }
                }

                // Public Transit Information
                if let transitAirport = airports.first(where: { $0.publicTransitAvailable }) {
                    Divider()
                        .background(Color.gray.opacity(0.3))

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "tram.fill")
                                .foregroundColor(Color("BasketballOrange"))
                                .font(.system(size: 16))

                            Text("Public Transit Available")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }

                        if let instructions = transitAirport.publicTransitInstructions {
                            Text(instructions)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(15)
        }
    }
}

struct AirportRow: View {
    let airport: Airport
    let isPrimary: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Airport Name and Code
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(airport.code)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(isPrimary ? Color("BasketballOrange") : .white)

                        Text(airport.name)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }

                    Text("\(airport.city), \(airport.state)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            // Distance and Time
            HStack(spacing: 20) {
                if let distance = airport.distanceFromVenue {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.0f miles", distance))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                if let driveTime = airport.estimatedDriveTime {
                    HStack(spacing: 4) {
                        Image(systemName: "car.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(driveTime) min drive")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                if airport.publicTransitAvailable {
                    HStack(spacing: 4) {
                        Image(systemName: "tram.fill")
                            .font(.caption)
                            .foregroundColor(Color("BasketballOrange"))
                        Text("Transit")
                            .font(.caption)
                            .foregroundColor(Color("BasketballOrange"))
                    }
                }
            }
        }
    }
}