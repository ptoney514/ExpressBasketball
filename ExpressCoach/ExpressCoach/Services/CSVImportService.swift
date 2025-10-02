//
//  CSVImportService.swift
//  ExpressCoach
//
//  Handles bulk player import from CSV files and Google Sheets
//

import Foundation
import SwiftData

// MARK: - CSV Import Models

struct CSVPlayerRow {
    let firstName: String
    let lastName: String
    let jerseyNumber: String
    let dateOfBirth: Date?
    let parentName: String?
    let parentPhone: String?
    let parentEmail: String?
    let position: String?
    let graduationYear: Int?
    let emergencyContact: String?
    let emergencyPhone: String?
    let medicalNotes: String?

    var isValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty
    }
}

struct CSVImportResult {
    let successCount: Int
    let failedRows: [(row: Int, reason: String)]
    let totalRows: Int

    var hasErrors: Bool {
        !failedRows.isEmpty
    }

    var successRate: Double {
        guard totalRows > 0 else { return 0 }
        return Double(successCount) / Double(totalRows)
    }
}

// MARK: - CSV Import Service

@MainActor
class CSVImportService {

    // MARK: - CSV Format

    /// Expected CSV column headers (case-insensitive, flexible order)
    enum CSVColumn: String, CaseIterable {
        case firstName = "first name"
        case lastName = "last name"
        case jerseyNumber = "jersey number"
        case dateOfBirth = "date of birth"
        case parentName = "parent name"
        case parentPhone = "parent phone"
        case parentEmail = "parent email"
        case position = "position"
        case graduationYear = "graduation year"
        case emergencyContact = "emergency contact"
        case emergencyPhone = "emergency phone"
        case medicalNotes = "medical notes"

        var aliases: [String] {
            switch self {
            case .firstName: return ["first", "firstname", "first_name"]
            case .lastName: return ["last", "lastname", "last_name"]
            case .jerseyNumber: return ["jersey", "number", "jersey_number", "#"]
            case .dateOfBirth: return ["dob", "birthday", "birth date", "birthdate", "date_of_birth", "birthdate"]
            case .parentName: return ["parent", "guardian name", "guardian", "parent_name", "guardian_name"]
            case .parentPhone: return ["phone", "guardian phone", "parent phone", "contact", "parent_phone", "guardian_phone"]
            case .parentEmail: return ["email", "guardian email", "parent email", "parent_email", "guardian_email"]
            case .position: return ["pos"]
            case .graduationYear: return ["grad year", "year", "class year", "graduation_year", "grad_year"]
            case .emergencyContact: return ["emergency", "emergency_contact"]
            case .emergencyPhone: return ["emergency phone", "emergency_phone"]
            case .medicalNotes: return ["medical", "notes", "medical_notes"]
            }
        }
    }

    // MARK: - Google Sheets URL Conversion

    /// Converts a Google Sheets sharing URL to CSV export URL
    /// - Parameter shareURL: The Google Sheets sharing URL (https://docs.google.com/spreadsheets/d/DOCID/edit...)
    /// - Returns: CSV export URL if valid, nil otherwise
    static func convertGoogleSheetsURL(_ shareURL: String) -> URL? {
        // Extract document ID from various Google Sheets URL formats
        let patterns = [
            #"docs\.google\.com/spreadsheets/d/([a-zA-Z0-9-_]+)"#,
            #"spreadsheets/d/([a-zA-Z0-9-_]+)"#
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: shareURL, range: NSRange(shareURL.startIndex..., in: shareURL)),
               let range = Range(match.range(at: 1), in: shareURL) {
                let docId = String(shareURL[range])

                // Extract gid (sheet ID) if present
                var gid: String?
                if let gidRegex = try? NSRegularExpression(pattern: #"gid=([0-9]+)"#),
                   let gidMatch = gidRegex.firstMatch(in: shareURL, range: NSRange(shareURL.startIndex..., in: shareURL)),
                   let gidRange = Range(gidMatch.range(at: 1), in: shareURL) {
                    gid = String(shareURL[gidRange])
                }

                // Construct CSV export URL
                var csvURLString = "https://docs.google.com/spreadsheets/d/\(docId)/export?format=csv"
                if let gid = gid {
                    csvURLString += "&gid=\(gid)"
                }

                return URL(string: csvURLString)
            }
        }

        return nil
    }

    // MARK: - CSV Parsing

    /// Parses CSV content into player rows
    func parseCSV(_ csvContent: String) throws -> [CSVPlayerRow] {
        let lines = csvContent.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard lines.count > 1 else {
            throw CSVImportError.emptyFile
        }

        // Parse header row
        let headerRow = lines[0]
        let headers = parseCSVLine(headerRow)
        let columnMap = mapColumns(headers: headers)

        guard columnMap[.firstName] != nil && columnMap[.lastName] != nil else {
            throw CSVImportError.missingRequiredColumns(["First Name", "Last Name"])
        }

        // Parse data rows
        var players: [CSVPlayerRow] = []
        for line in lines.dropFirst() {
            let values = parseCSVLine(line)
            if let player = parsePlayerRow(values: values, columnMap: columnMap) {
                players.append(player)
            }
        }

        return players
    }

    /// Downloads and parses CSV from URL (supports Google Sheets export URLs)
    func downloadAndParseCSV(from url: URL) async throws -> [CSVPlayerRow] {
        let (data, _) = try await URLSession.shared.data(from: url)

        guard let csvContent = String(data: data, encoding: .utf8) else {
            throw CSVImportError.invalidEncoding
        }

        return try parseCSV(csvContent)
    }

    // MARK: - Player Import

    /// Imports players into SwiftData for a specific team
    func importPlayers(
        _ playerRows: [CSVPlayerRow],
        to team: Team,
        modelContext: ModelContext
    ) -> CSVImportResult {
        var successCount = 0
        var failedRows: [(row: Int, reason: String)] = []

        for (index, row) in playerRows.enumerated() {
            let rowNumber = index + 2 // +2 because of header row and 1-based indexing

            guard row.isValid else {
                failedRows.append((rowNumber, "Missing required fields (First Name, Last Name)"))
                continue
            }

            do {
                // Calculate graduation year from date of birth if not provided
                let gradYear: Int
                if let providedYear = row.graduationYear {
                    gradYear = providedYear
                } else if let dob = row.dateOfBirth {
                    // Estimate graduation year (typically age 18, so birth year + 18)
                    let calendar = Calendar.current
                    let birthYear = calendar.component(.year, from: dob)
                    gradYear = birthYear + 18
                } else {
                    // Default to current year + 4 if nothing else available
                    gradYear = Calendar.current.component(.year, from: Date()) + 4
                }

                let player = Player(
                    firstName: row.firstName,
                    lastName: row.lastName,
                    jerseyNumber: row.jerseyNumber.isEmpty ? "0" : row.jerseyNumber,
                    position: row.position ?? "Forward",
                    graduationYear: gradYear,
                    parentName: row.parentName ?? "",
                    parentEmail: row.parentEmail ?? "",
                    parentPhone: row.parentPhone ?? "",
                    emergencyContact: row.emergencyContact ?? "",
                    emergencyPhone: row.emergencyPhone ?? ""
                )

                player.birthDate = row.dateOfBirth
                player.medicalNotes = row.medicalNotes

                // Add player to team
                if player.teams == nil {
                    player.teams = []
                }
                player.teams?.append(team)

                modelContext.insert(player)
                successCount += 1
            } catch {
                failedRows.append((rowNumber, "Failed to create player: \(error.localizedDescription)"))
            }
        }

        // Save all changes
        do {
            try modelContext.save()
        } catch {
            // If save fails, report it for all successful rows
            for i in 0..<successCount {
                failedRows.append((i + 2, "Failed to save: \(error.localizedDescription)"))
            }
            successCount = 0
        }

        return CSVImportResult(
            successCount: successCount,
            failedRows: failedRows,
            totalRows: playerRows.count
        )
    }

    // MARK: - CSV Generation (Export)

    /// Generates CSV content from players
    func generateCSV(from players: [Player]) -> String {
        var csv = "First Name,Last Name,Jersey Number,Date of Birth,Parent Name,Parent Phone,Parent Email,Position,Graduation Year,Emergency Contact,Emergency Phone,Medical Notes\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        for player in players {
            let row = [
                escapeCSVField(player.firstName),
                escapeCSVField(player.lastName),
                escapeCSVField(player.jerseyNumber),
                player.birthDate.map { dateFormatter.string(from: $0) } ?? "",
                escapeCSVField(player.parentName ?? ""),
                escapeCSVField(player.parentPhone ?? ""),
                escapeCSVField(player.parentEmail ?? ""),
                escapeCSVField(player.position),
                String(player.graduationYear),
                escapeCSVField(player.emergencyContact ?? ""),
                escapeCSVField(player.emergencyPhone ?? ""),
                escapeCSVField(player.medicalNotes ?? "")
            ]
            csv += row.joined(separator: ",") + "\n"
        }

        return csv
    }

    /// Generates a sample CSV template for users
    static func generateSampleTemplate() -> String {
        """
        First Name,Last Name,Jersey Number,Date of Birth,Parent Name,Parent Phone,Parent Email,Position,Graduation Year,Emergency Contact,Emergency Phone,Medical Notes
        John,Smith,12,03/15/2010,Jane Smith,(555) 123-4567,jane@email.com,Point Guard,2028,Jane Smith,(555) 123-4567,None
        Sarah,Johnson,23,07/22/2011,Mike Johnson,(555) 234-5678,mike@email.com,Shooting Guard,2029,Mike Johnson,(555) 234-5678,Asthma inhaler
        Michael,Williams,7,11/05/2009,Lisa Williams,(555) 345-6789,lisa@email.com,Center,2027,Lisa Williams,(555) 345-6789,None
        """
    }

    // MARK: - Private Helpers

    private func parseCSVLine(_ line: String) -> [String] {
        var values: [String] = []
        var currentValue = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                values.append(currentValue.trimmingCharacters(in: .whitespaces))
                currentValue = ""
            } else {
                currentValue.append(char)
            }
        }

        values.append(currentValue.trimmingCharacters(in: .whitespaces))
        return values
    }

    private func mapColumns(headers: [String]) -> [CSVColumn: Int] {
        var map: [CSVColumn: Int] = [:]

        for (index, header) in headers.enumerated() {
            let normalizedHeader = header.lowercased().trimmingCharacters(in: .whitespaces)

            for column in CSVColumn.allCases {
                if normalizedHeader == column.rawValue || column.aliases.contains(normalizedHeader) {
                    map[column] = index
                    break
                }
            }
        }

        return map
    }

    private func parsePlayerRow(values: [String], columnMap: [CSVColumn: Int]) -> CSVPlayerRow? {
        guard let firstNameIdx = columnMap[.firstName],
              let lastNameIdx = columnMap[.lastName],
              firstNameIdx < values.count,
              lastNameIdx < values.count else {
            return nil
        }

        let firstName = values[firstNameIdx]
        let lastName = values[lastNameIdx]

        guard !firstName.isEmpty && !lastName.isEmpty else {
            return nil
        }

        // Parse optional fields
        let jerseyNumber = columnMap[.jerseyNumber].flatMap { values[safe: $0] } ?? ""
        let dateOfBirth = columnMap[.dateOfBirth].flatMap { values[safe: $0] }.flatMap(parseDate)
        let parentName = columnMap[.parentName].flatMap { values[safe: $0] }
        let parentPhone = columnMap[.parentPhone].flatMap { values[safe: $0] }
        let parentEmail = columnMap[.parentEmail].flatMap { values[safe: $0] }
        let position = columnMap[.position].flatMap { values[safe: $0] }
        let graduationYear = columnMap[.graduationYear].flatMap { values[safe: $0] }.flatMap { Int($0) }
        let emergencyContact = columnMap[.emergencyContact].flatMap { values[safe: $0] }
        let emergencyPhone = columnMap[.emergencyPhone].flatMap { values[safe: $0] }
        let medicalNotes = columnMap[.medicalNotes].flatMap { values[safe: $0] }

        return CSVPlayerRow(
            firstName: firstName,
            lastName: lastName,
            jerseyNumber: jerseyNumber,
            dateOfBirth: dateOfBirth,
            parentName: parentName,
            parentPhone: parentPhone,
            parentEmail: parentEmail,
            position: position,
            graduationYear: graduationYear,
            emergencyContact: emergencyContact,
            emergencyPhone: emergencyPhone,
            medicalNotes: medicalNotes
        )
    }

    private func parseDate(_ dateString: String) -> Date? {
        let formatters = [
            "MM/dd/yyyy",
            "M/d/yyyy",
            "yyyy-MM-dd",
            "MM-dd-yyyy"
        ].map { format -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter
        }

        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }

    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
}

// MARK: - Errors

enum CSVImportError: LocalizedError {
    case emptyFile
    case missingRequiredColumns([String])
    case invalidEncoding
    case downloadFailed(Error)
    case invalidGoogleSheetsURL

    var errorDescription: String? {
        switch self {
        case .emptyFile:
            return "CSV file is empty or contains no data rows"
        case .missingRequiredColumns(let columns):
            return "CSV is missing required columns: \(columns.joined(separator: ", "))"
        case .invalidEncoding:
            return "CSV file encoding is not supported (use UTF-8)"
        case .downloadFailed(let error):
            return "Failed to download CSV: \(error.localizedDescription)"
        case .invalidGoogleSheetsURL:
            return "Invalid Google Sheets URL. Make sure the sheet is publicly accessible."
        }
    }
}

// MARK: - Array Extension

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}