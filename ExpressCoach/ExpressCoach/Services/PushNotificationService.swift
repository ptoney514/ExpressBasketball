//
//  PushNotificationService.swift
//  ExpressCoach
//
//  Manages sending push notifications to parents via Supabase Edge Functions
//

import Foundation
import Combine

@MainActor
class PushNotificationService: ObservableObject {
    static let shared = PushNotificationService()

    @Published var isSending = false
    @Published var lastSentCount: Int?
    @Published var lastError: String?

    private let supabaseURL = "https://scpluslhcastrobigkfb.supabase.co"
    private let serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjcGx1c2xoY2FzdHJvYmlna2ZiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNjk1ODgzMSwiZXhwIjoyMDQyNTM0ODMxfQ.mPZftvQYG9F9qQoX01z0B0nQdpLaDlVW4DQJRKtTw5M"

    private init() {}

    // MARK: - Send Push Notifications

    /// Send push notification to all parents on a team
    func sendPushNotification(
        teamId: UUID,
        title: String,
        body: String,
        type: NotificationType,
        badge: Int? = nil
    ) async throws -> Int {
        isSending = true
        lastError = nil

        defer {
            isSending = false
        }

        let endpoint = "\(supabaseURL)/functions/v1/send-push-notification"

        guard let url = URL(string: endpoint) else {
            throw PushNotificationError.invalidURL
        }

        let payload: [String: Any] = [
            "teamId": teamId.uuidString,
            "title": title,
            "body": body,
            "type": type.rawValue,
            "badge": badge as Any
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(serviceRoleKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PushNotificationError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Push notification failed: \(errorMessage)")
            lastError = errorMessage
            throw PushNotificationError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // Parse response
        let responseData = try JSONDecoder().decode(PushNotificationResponse.self, from: data)

        let sentCount = responseData.sent
        lastSentCount = sentCount

        print("✅ Push notification sent to \(sentCount) devices")

        return sentCount
    }

    /// Send announcement notification
    func sendAnnouncementNotification(
        teamId: UUID,
        title: String,
        content: String
    ) async throws -> Int {
        return try await sendPushNotification(
            teamId: teamId,
            title: title,
            body: content,
            type: .announcement,
            badge: 1
        )
    }

    /// Send schedule update notification
    func sendScheduleNotification(
        teamId: UUID,
        title: String,
        details: String
    ) async throws -> Int {
        return try await sendPushNotification(
            teamId: teamId,
            title: title,
            body: details,
            type: .scheduleChange,
            badge: 1
        )
    }

    /// Send game reminder notification
    func sendGameReminder(
        teamId: UUID,
        opponent: String,
        time: String,
        location: String
    ) async throws -> Int {
        let title = "Game Tomorrow"
        let body = "vs \(opponent) at \(time)\n📍 \(location)"

        return try await sendPushNotification(
            teamId: teamId,
            title: title,
            body: body,
            type: .gameReminder,
            badge: 1
        )
    }

    /// Send practice reminder notification
    func sendPracticeReminder(
        teamId: UUID,
        time: String,
        location: String
    ) async throws -> Int {
        let title = "Practice Tomorrow"
        let body = "Practice at \(time)\n📍 \(location)"

        return try await sendPushNotification(
            teamId: teamId,
            title: title,
            body: body,
            type: .practiceReminder,
            badge: 1
        )
    }
}

// MARK: - Models

enum NotificationType: String {
    case announcement = "announcement"
    case scheduleChange = "schedule_change"
    case gameReminder = "game_reminder"
    case practiceReminder = "practice_reminder"
}

struct PushNotificationResponse: Decodable {
    let success: Bool
    let sent: Int
    let failed: Int
    let message: String?
}

enum PushNotificationError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case encodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid push notification endpoint URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .encodingError:
            return "Failed to encode notification data"
        }
    }
}
