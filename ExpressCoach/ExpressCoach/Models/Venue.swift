//
//  Venue.swift
//  ExpressCoach
//
//  Created on 9/21/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Venue {
    var id: UUID
    var name: String
    var fullAddress: String
    var streetAddress: String
    var city: String
    var state: String
    var zipCode: String
    var latitude: Double?
    var longitude: Double?
    var phone: String?
    var website: String?
    var capacity: Int?
    var courtCount: Int?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    // Relationships
    @Relationship(deleteRule: .cascade) var parkingOptions: [ParkingOption]?
    @Relationship(deleteRule: .nullify) var nearbyHotels: [Hotel]?
    @Relationship(deleteRule: .nullify) var nearbyAirports: [Airport]?
    // Relationships with other models
    @Relationship(deleteRule: .nullify) var schedules: [Schedule]?
    @Relationship(deleteRule: .nullify) var events: [Event]?

    init(
        name: String,
        streetAddress: String,
        city: String,
        state: String,
        zipCode: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        phone: String? = nil,
        website: String? = nil,
        capacity: Int? = nil,
        courtCount: Int? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.fullAddress = "\(streetAddress), \(city), \(state) \(zipCode)"
        self.latitude = latitude
        self.longitude = longitude
        self.phone = phone
        self.website = website
        self.capacity = capacity
        self.courtCount = courtCount
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

@Model
final class Hotel {
    var id: UUID
    var name: String
    var brandName: String? // e.g., "Marriott", "Hilton"
    var fullAddress: String
    var streetAddress: String
    var city: String
    var state: String
    var zipCode: String
    var phone: String
    var website: String?
    var distanceFromVenue: Double? // in miles
    var teamRate: Double?
    var teamRateCode: String?
    var bookingInstructions: String?
    var checkInTime: String?
    var checkOutTime: String?
    var amenities: [String]
    var isOfficialHotel: Bool
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    // Relationships
    var venues: [Venue]?
    var schedules: [Schedule]?

    init(
        name: String,
        streetAddress: String,
        city: String,
        state: String,
        zipCode: String,
        phone: String,
        distanceFromVenue: Double? = nil,
        teamRate: Double? = nil,
        teamRateCode: String? = nil,
        bookingInstructions: String? = nil,
        amenities: [String] = [],
        isOfficialHotel: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.fullAddress = "\(streetAddress), \(city), \(state) \(zipCode)"
        self.phone = phone
        self.distanceFromVenue = distanceFromVenue
        self.teamRate = teamRate
        self.teamRateCode = teamRateCode
        self.bookingInstructions = bookingInstructions
        self.amenities = amenities
        self.isOfficialHotel = isOfficialHotel
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
final class Airport {
    var id: UUID
    var name: String
    var code: String // IATA code (e.g., "LAX", "JFK")
    var fullAddress: String?
    var city: String
    var state: String
    var distanceFromVenue: Double? // in miles
    var estimatedDriveTime: Int? // in minutes
    var publicTransitAvailable: Bool
    var publicTransitInstructions: String?
    var isPrimary: Bool
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    // Relationships
    var venues: [Venue]?

    init(
        name: String,
        code: String,
        city: String,
        state: String,
        distanceFromVenue: Double? = nil,
        estimatedDriveTime: Int? = nil,
        publicTransitAvailable: Bool = false,
        publicTransitInstructions: String? = nil,
        isPrimary: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.code = code
        self.city = city
        self.state = state
        self.distanceFromVenue = distanceFromVenue
        self.estimatedDriveTime = estimatedDriveTime
        self.publicTransitAvailable = publicTransitAvailable
        self.publicTransitInstructions = publicTransitInstructions
        self.isPrimary = isPrimary
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
final class ParkingOption {
    var id: UUID
    var name: String
    var type: ParkingType
    var location: String
    var distanceFromVenue: Double? // in miles or blocks
    var pricing: String
    var dailyRate: Double?
    var eventRate: Double?
    var capacity: Int?
    var isPreferred: Bool
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    // Relationships
    var venue: Venue?

    init(
        name: String,
        type: ParkingType,
        location: String,
        pricing: String,
        distanceFromVenue: Double? = nil,
        dailyRate: Double? = nil,
        eventRate: Double? = nil,
        capacity: Int? = nil,
        isPreferred: Bool = false,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.location = location
        self.pricing = pricing
        self.distanceFromVenue = distanceFromVenue
        self.dailyRate = dailyRate
        self.eventRate = eventRate
        self.capacity = capacity
        self.isPreferred = isPreferred
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    enum ParkingType: String, CaseIterable, Codable {
        case venueParking = "Venue Parking"
        case streetParking = "Street Parking"
        case publicGarage = "Public Garage"
        case privateLot = "Private Lot"
        case valet = "Valet"
    }
}
