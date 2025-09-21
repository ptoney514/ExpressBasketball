//
//  VenueDetailSection.swift
//  ExpressCoach
//
//  Created on 9/21/25.
//

import SwiftUI
import MapKit

struct VenueDetailSection: View {
    let venue: Venue
    @State private var region = MKCoordinateRegion()
    @State private var showingMap = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(Color("BasketballOrange"))
                    .font(.system(size: 20))

                Text("Venue Information")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()
            }

            // Venue Details Card
            VStack(alignment: .leading, spacing: 12) {
                // Venue Name
                Text(venue.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                // Address
                VStack(alignment: .leading, spacing: 4) {
                    Text(venue.streetAddress)
                        .foregroundColor(.gray)
                    Text("\(venue.city), \(venue.state) \(venue.zipCode)")
                        .foregroundColor(.gray)
                }
                .font(.subheadline)

                // Additional Details
                HStack(spacing: 20) {
                    if let capacity = venue.capacity {
                        Label("\(capacity) capacity", systemImage: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    if let courts = venue.courtCount {
                        Label("\(courts) court\(courts != 1 ? "s" : "")", systemImage: "sportscourt.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                if let phone = venue.phone {
                    Button(action: {
                        if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label(phone, systemImage: "phone.fill")
                            .font(.subheadline)
                            .foregroundColor(Color("BasketballOrange"))
                    }
                }

                // Map Preview
                if let coordinate = venue.coordinate {
                    MapPreviewCard(coordinate: coordinate, venueName: venue.name)
                        .frame(height: 150)
                        .cornerRadius(12)
                        .onTapGesture {
                            showingMap = true
                        }
                }

                // Directions Button
                Button(action: {
                    openInMaps()
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Get Directions")
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
        .sheet(isPresented: $showingMap) {
            if let coordinate = venue.coordinate {
                FullMapView(coordinate: coordinate, venueName: venue.name)
            }
        }
    }

    private func openInMaps() {
        let addressString = "\(venue.streetAddress), \(venue.city), \(venue.state) \(venue.zipCode)"
        let encodedAddress = addressString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "maps://?daddr=\(encodedAddress)") {
            UIApplication.shared.open(url)
        }
    }
}

struct MapPreviewCard: View {
    let coordinate: CLLocationCoordinate2D
    let venueName: String
    @State private var region: MKCoordinateRegion

    init(coordinate: CLLocationCoordinate2D, venueName: String) {
        self.coordinate = coordinate
        self.venueName = venueName
        self._region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [MapPin(coordinate: coordinate)]) { pin in
            MapAnnotation(coordinate: pin.coordinate) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(Color("BasketballOrange"))
                    .font(.title)
            }
        }
        .disabled(true)
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding(8)
                }
            }
        )
    }
}

struct FullMapView: View {
    let coordinate: CLLocationCoordinate2D
    let venueName: String
    @State private var region: MKCoordinateRegion
    @Environment(\.dismiss) private var dismiss

    init(coordinate: CLLocationCoordinate2D, venueName: String) {
        self.coordinate = coordinate
        self.venueName = venueName
        self._region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        ))
    }

    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, annotationItems: [MapPin(coordinate: coordinate)]) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color("BasketballOrange"))
                            .font(.title)
                        Text(venueName)
                            .font(.caption)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(4)
                    }
                }
            }
            .ignoresSafeArea()
            .navigationTitle(venueName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}