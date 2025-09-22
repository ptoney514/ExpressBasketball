//
//  Constants.swift
//  ExpressCoach
//
//  App-wide constants and configuration
//

import Foundation
import SwiftUI

enum AppConstants {

    enum Roster {
        static let defaultYearsAhead = 6
        static let maxGraduationYearsRange = 15
        static let jerseyNumberMaxLength = 3
        static let minJerseyNumber = 0
        static let maxJerseyNumber = 999
        static let maxPlayersPerTeam = 50
        static let searchDebounceDelay: TimeInterval = 0.3
    }

    enum Validation {
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        static let phoneRegex = "^[0-9+\\-\\(\\)\\s]{10,20}$"
        static let minNameLength = 1
        static let maxNameLength = 50
    }

    enum UI {
        static let standardAnimationDuration: Double = 0.25
        static let quickAnimationDuration: Double = 0.15
        static let slowAnimationDuration: Double = 0.35
        static let cornerRadius: CGFloat = 10
        static let shadowRadius: CGFloat = 5
        static let standardPadding: CGFloat = 16
        static let compactPadding: CGFloat = 8
    }

    enum ErrorMessages {
        static let genericError = "An unexpected error occurred. Please try again."
        static let saveFailed = "Failed to save changes. Please try again."
        static let deleteFailed = "Failed to delete. Please try again."
        static let loadFailed = "Failed to load data. Please try again."
        static let invalidEmail = "Please enter a valid email address."
        static let invalidPhone = "Please enter a valid phone number."
        static let duplicateJersey = "Jersey number is already taken by another player on this team."
        static let requiredField = "This field is required."
        static let networkError = "Network connection error. Please check your connection."
    }

    enum SuccessMessages {
        static let playerAdded = "Player added successfully!"
        static let playerUpdated = "Player updated successfully!"
        static let playerDeleted = "Player removed from roster."
        static let changesSaved = "Changes saved successfully!"
    }

    enum Accessibility {
        static let deletePlayerHint = "Double tap to remove player from roster"
        static let editPlayerHint = "Double tap to edit player information"
        static let viewPlayerHint = "Double tap to view player details"
        static let addPlayerHint = "Double tap to add a new player to the roster"
        static let selectTeamHint = "Double tap to view team roster"
    }

    enum HapticFeedback {
        static let enableHaptics = true
        static let deleteConfirmation = true
        static let saveSuccess = true
        static let errorOccurred = true
    }
}