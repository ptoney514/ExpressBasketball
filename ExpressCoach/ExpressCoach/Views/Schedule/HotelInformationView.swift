//
//  HotelInformationView.swift
//  ExpressCoach
//
//  Created on 9/21/25.
//

import SwiftUI

struct HotelInformationView: View {
    let hotel: Hotel
    let isPrimary: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "bed.double.fill")
                    .foregroundColor(Color("BasketballOrange"))
                    .font(.system(size: 20))

                Text(isPrimary ? "Official Tournament Hotel" : "Hotel Information")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if isPrimary {
                    Text("TEAM RATE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("BasketballOrange"))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }

            // Hotel Card
            VStack(alignment: .leading, spacing: 16) {
                // Hotel Name and Brand
                VStack(alignment: .leading, spacing: 4) {
                    Text(hotel.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if let brand = hotel.brandName {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                // Address
                VStack(alignment: .leading, spacing: 4) {
                    Text(hotel.streetAddress)
                        .foregroundColor(.gray)
                    Text("\(hotel.city), \(hotel.state) \(hotel.zipCode)")
                        .foregroundColor(.gray)
                }
                .font(.subheadline)

                // Contact and Distance
                HStack(spacing: 20) {
                    Button(action: {
                        if let url = URL(string: "tel://\(hotel.phone.replacingOccurrences(of: " ", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label(hotel.phone, systemImage: "phone.fill")
                            .font(.subheadline)
                            .foregroundColor(Color("BasketballOrange"))
                    }

                    if let distance = hotel.distanceFromVenue {
                        Label(String(format: "%.1f miles from venue", distance), systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // Team Rate Information
                if let teamRate = hotel.teamRate {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()
                            .background(Color.gray.opacity(0.3))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Special Team Rate")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            HStack(alignment: .top, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Rate")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(String(format: "$%.0f/night", teamRate))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("BasketballOrange"))
                                }

                                if let code = hotel.teamRateCode {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Booking Code")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(code)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.3))
                                            .cornerRadius(4)
                                    }
                                }
                            }

                            if let instructions = hotel.bookingInstructions {
                                Text(instructions)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .italic()
                            }
                        }
                    }
                }

                // Amenities
                if !hotel.amenities.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                            .background(Color.gray.opacity(0.3))

                        Text("Amenities")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                            ForEach(hotel.amenities, id: \.self) { amenity in
                                HStack {
                                    Image(systemName: amenityIcon(for: amenity))
                                        .foregroundColor(Color("BasketballOrange"))
                                        .font(.caption)
                                    Text(amenity)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }

                // Check-in/Check-out Times
                if let checkIn = hotel.checkInTime, let checkOut = hotel.checkOutTime {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Check-in")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(checkIn)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Check-out")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(checkOut)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }

                // Book Hotel Button
                Button(action: {
                    bookHotel()
                }) {
                    HStack {
                        Image(systemName: "safari.fill")
                        Text("Book Hotel Room")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("BasketballOrange"))
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(15)
        }
    }

    private func amenityIcon(for amenity: String) -> String {
        switch amenity.lowercased() {
        case let s where s.contains("wifi") || s.contains("internet"):
            return "wifi"
        case let s where s.contains("pool") || s.contains("swim"):
            return "drop.fill"
        case let s where s.contains("fitness") || s.contains("gym"):
            return "figure.strengthtraining.traditional"
        case let s where s.contains("breakfast") || s.contains("food"):
            return "fork.knife"
        case let s where s.contains("shuttle") || s.contains("transport"):
            return "bus.fill"
        case let s where s.contains("parking"):
            return "car.fill"
        case let s where s.contains("pet") || s.contains("animal"):
            return "pawprint.fill"
        case let s where s.contains("laundry"):
            return "washer.fill"
        case let s where s.contains("business"):
            return "briefcase.fill"
        default:
            return "star.fill"
        }
    }

    private func bookHotel() {
        if let website = hotel.website,
           let url = URL(string: website) {
            UIApplication.shared.open(url)
        } else {
            // Fallback to a Google search for the hotel
            let searchQuery = "\(hotel.name) \(hotel.city) \(hotel.state)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "https://www.google.com/search?q=\(searchQuery)") {
                UIApplication.shared.open(url)
            }
        }
    }
}