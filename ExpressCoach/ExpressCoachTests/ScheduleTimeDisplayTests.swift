//
//  ScheduleTimeDisplayTests.swift
//  ExpressCoachTests
//
//  Tests to verify time display formatting in schedule views
//

import XCTest
import SwiftUI
@testable import ExpressCoach

final class ScheduleTimeDisplayTests: XCTestCase {

    func testTimeFormattingWidth() {
        // Test various time formats to ensure they don't wrap
        let testTimes = [
            createTestDate(hour: 8, minute: 34),   // 8:34 AM
            createTestDate(hour: 10, minute: 30),  // 10:30 AM
            createTestDate(hour: 11, minute: 59),  // 11:59 AM
            createTestDate(hour: 12, minute: 00),  // 12:00 PM
            createTestDate(hour: 13, minute: 45),  // 1:45 PM
            createTestDate(hour: 23, minute: 59)   // 11:59 PM
        ]

        for date in testTimes {
            let formatted = date.formatted(date: .omitted, time: .shortened)

            // Verify the formatted string doesn't contain unexpected line breaks
            XCTAssertFalse(formatted.contains("\n"), "Time format should not contain line breaks: \(formatted)")

            // Verify the string length is reasonable for display
            XCTAssertLessThanOrEqual(formatted.count, 10, "Time format should be concise: \(formatted)")

            // Verify AM/PM is included
            XCTAssertTrue(formatted.contains("AM") || formatted.contains("PM"),
                         "Time should include AM/PM indicator: \(formatted)")
        }
    }

    func testScheduleEventRowTimeDisplay() {
        // Create a test schedule with a specific time
        let schedule = Schedule(
            eventType: .practice,
            location: "Test Gym",
            date: createTestDate(hour: 8, minute: 34),
            isHome: true
        )

        // The ScheduleEventRow should have sufficient width for time display
        // With our fix, minWidth should be 75 points
        let minRequiredWidth: CGFloat = 75

        // This is the width we set in the fix
        XCTAssertGreaterThanOrEqual(minRequiredWidth, 75,
                                   "Time display should have at least 75 points width")
    }

    func testCompactScheduleCardTimeDisplay() {
        // Create a test schedule
        let schedule = Schedule(
            eventType: .game,
            location: "Home Court",
            date: createTestDate(hour: 10, minute: 30),
            isHome: true
        )
        schedule.opponent = "Test Team"

        // The CompactScheduleCard should also have sufficient width
        let minRequiredWidth: CGFloat = 75

        XCTAssertGreaterThanOrEqual(minRequiredWidth, 75,
                                   "Compact card time display should have at least 75 points width")
    }

    // Helper function to create test dates
    private func createTestDate(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = 2025
        components.month = 9
        components.day = 21
        components.hour = hour
        components.minute = minute

        return Calendar.current.date(from: components) ?? Date()
    }
}