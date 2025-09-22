//
//  ValidationHelper.swift
//  ExpressCoach
//
//  Input validation utilities
//

import Foundation
import SwiftData

enum ValidationError: LocalizedError {
    case invalidEmail
    case invalidPhone
    case duplicateJerseyNumber
    case requiredField(String)
    case invalidJerseyNumber
    case nameTooLong(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return AppConstants.ErrorMessages.invalidEmail
        case .invalidPhone:
            return AppConstants.ErrorMessages.invalidPhone
        case .duplicateJerseyNumber:
            return AppConstants.ErrorMessages.duplicateJersey
        case .requiredField(let field):
            return "\(field) is required"
        case .invalidJerseyNumber:
            return "Jersey number must be between \(AppConstants.Roster.minJerseyNumber) and \(AppConstants.Roster.maxJerseyNumber)"
        case .nameTooLong(let field):
            return "\(field) cannot exceed \(AppConstants.Validation.maxNameLength) characters"
        }
    }
}

@MainActor
class ValidationHelper {

    static func validateEmail(_ email: String) -> Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", AppConstants.Validation.emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    static func validatePhone(_ phone: String) -> Bool {
        let cleanedPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleanedPhone.count >= 10 && cleanedPhone.count <= 15
    }

    static func validateJerseyNumber(_ number: String) -> Bool {
        guard !number.isEmpty,
              let jerseyInt = Int(number) else {
            return false
        }

        return jerseyInt >= AppConstants.Roster.minJerseyNumber &&
               jerseyInt <= AppConstants.Roster.maxJerseyNumber
    }

    static func validateName(_ name: String, fieldName: String) throws {
        if name.isEmpty {
            throw ValidationError.requiredField(fieldName)
        }
        if name.count > AppConstants.Validation.maxNameLength {
            throw ValidationError.nameTooLong(fieldName)
        }
    }

    static func isJerseyNumberUnique(
        _ number: String,
        for team: Team,
        excluding player: Player? = nil,
        in modelContext: ModelContext
    ) -> Bool {
        guard let players = team.players else { return true }

        return !players.contains { existingPlayer in
            existingPlayer.jerseyNumber == number &&
            existingPlayer.id != player?.id
        }
    }

    static func formatPhoneNumber(_ phone: String) -> String {
        let cleanedPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)

        guard cleanedPhone.count == 10 else { return phone }

        let areaCode = cleanedPhone.prefix(3)
        let middle = cleanedPhone.dropFirst(3).prefix(3)
        let last = cleanedPhone.suffix(4)

        return "(\(areaCode)) \(middle)-\(last)"
    }

    static func validatePlayerForm(
        firstName: String,
        lastName: String,
        jerseyNumber: String,
        parentName: String,
        parentEmail: String,
        parentPhone: String,
        emergencyContact: String,
        emergencyPhone: String
    ) -> ValidationError? {
        // Check required fields
        if firstName.isEmpty { return .requiredField("First name") }
        if lastName.isEmpty { return .requiredField("Last name") }
        if jerseyNumber.isEmpty { return .requiredField("Jersey number") }
        if parentName.isEmpty { return .requiredField("Parent name") }
        if parentEmail.isEmpty { return .requiredField("Parent email") }
        if parentPhone.isEmpty { return .requiredField("Parent phone") }
        if emergencyContact.isEmpty { return .requiredField("Emergency contact") }
        if emergencyPhone.isEmpty { return .requiredField("Emergency phone") }

        // Validate formats
        if !validateEmail(parentEmail) { return .invalidEmail }
        if !validatePhone(parentPhone) { return .invalidPhone }
        if !validatePhone(emergencyPhone) { return .invalidPhone }
        if !validateJerseyNumber(jerseyNumber) { return .invalidJerseyNumber }

        // Check name lengths
        if firstName.count > AppConstants.Validation.maxNameLength {
            return .nameTooLong("First name")
        }
        if lastName.count > AppConstants.Validation.maxNameLength {
            return .nameTooLong("Last name")
        }

        return nil
    }

    static func sanitizeInput(_ input: String) -> String {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}