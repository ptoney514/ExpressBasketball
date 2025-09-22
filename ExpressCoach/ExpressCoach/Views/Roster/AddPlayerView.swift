//
//  AddPlayerView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData

struct AddPlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var alertManager = AlertManager()

    let team: Team

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var jerseyNumber = ""
    @State private var position = "Guard"
    @State private var graduationYear = Calendar.current.component(.year, from: Date()) + AppConstants.Roster.defaultYearsAhead
    @State private var height = ""
    @State private var birthDate = Date()

    @State private var parentName = ""
    @State private var parentEmail = ""
    @State private var parentPhone = ""
    @State private var emergencyContact = ""
    @State private var emergencyPhone = ""
    @State private var medicalNotes = ""

    @State private var isLoading = false

    let positions = ["Guard", "Forward", "Center", "Point Guard", "Shooting Guard", "Small Forward", "Power Forward"]
    let currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        NavigationStack {
            Form {
                Section("Player Information") {
                    TextField("First Name", text: $firstName)
                        .textContentType(.givenName)
                        .accessibilityLabel("First name")
                        .accessibilityHint("Required field")

                    TextField("Last Name", text: $lastName)
                        .textContentType(.familyName)
                        .accessibilityLabel("Last name")
                        .accessibilityHint("Required field")

                    TextField("Jersey Number", text: $jerseyNumber)
                        .keyboardType(.numberPad)
                        .accessibilityLabel("Jersey number")
                        .accessibilityHint("Required field, must be unique")

                    Picker("Position", selection: $position) {
                        ForEach(positions, id: \.self) { position in
                            Text(position).tag(position)
                        }
                    }

                    Picker("Graduation Year", selection: $graduationYear) {
                        ForEach((currentYear...(currentYear + AppConstants.Roster.maxGraduationYearsRange)), id: \.self) { year in
                            Text("Class of \(year)").tag(year)
                        }
                    }

                    TextField("Height (optional)", text: $height)
                        .keyboardType(.decimalPad)

                    DatePicker("Birth Date (optional)",
                              selection: $birthDate,
                              displayedComponents: .date)
                }

                Section("Parent/Guardian Information") {
                    TextField("Parent/Guardian Name", text: $parentName)
                        .textContentType(.name)
                        .accessibilityLabel("Parent or guardian name")
                        .accessibilityHint("Required field")

                    TextField("Email", text: $parentEmail)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .onChange(of: parentEmail) { _, newValue in
                            parentEmail = ValidationHelper.sanitizeInput(newValue)
                        }
                        .accessibilityLabel("Parent email")
                        .accessibilityHint("Required field")

                    TextField("Phone Number", text: $parentPhone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .onChange(of: parentPhone) { _, newValue in
                            parentPhone = ValidationHelper.formatPhoneNumber(newValue)
                        }
                        .accessibilityLabel("Parent phone number")
                        .accessibilityHint("Required field")
                }

                Section("Emergency Contact") {
                    TextField("Emergency Contact Name", text: $emergencyContact)
                        .textContentType(.name)
                        .accessibilityLabel("Emergency contact name")
                        .accessibilityHint("Required field")

                    TextField("Emergency Phone", text: $emergencyPhone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .onChange(of: emergencyPhone) { _, newValue in
                            emergencyPhone = ValidationHelper.formatPhoneNumber(newValue)
                        }
                        .accessibilityLabel("Emergency phone number")
                        .accessibilityHint("Required field")
                }

                Section("Medical Information") {
                    TextField("Medical Notes (optional)", text: $medicalNotes, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityLabel("Medical notes")
                        .accessibilityHint("Optional field for medical information")
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        HapticManager.shared.mediumImpact()
                        validateAndSavePlayer()
                    }
                    .bold()
                    .disabled(!isFormValid || isLoading)
                }
            }
            .loadingOverlay(isLoading: isLoading, message: "Saving player...")
            .withAlertManager(alertManager)
        }
    }

    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !jerseyNumber.isEmpty &&
        !parentName.isEmpty &&
        !parentEmail.isEmpty &&
        !parentPhone.isEmpty &&
        !emergencyContact.isEmpty &&
        !emergencyPhone.isEmpty
    }

    private func validateAndSavePlayer() {
        // Sanitize inputs
        let cleanFirstName = ValidationHelper.sanitizeInput(firstName)
        let cleanLastName = ValidationHelper.sanitizeInput(lastName)
        let cleanJerseyNumber = ValidationHelper.sanitizeInput(jerseyNumber)
        let cleanParentName = ValidationHelper.sanitizeInput(parentName)
        let cleanParentEmail = ValidationHelper.sanitizeInput(parentEmail)
        let cleanEmergencyContact = ValidationHelper.sanitizeInput(emergencyContact)

        // Validate all inputs
        if let error = ValidationHelper.validatePlayerForm(
            firstName: cleanFirstName,
            lastName: cleanLastName,
            jerseyNumber: cleanJerseyNumber,
            parentName: cleanParentName,
            parentEmail: cleanParentEmail,
            parentPhone: parentPhone,
            emergencyContact: cleanEmergencyContact,
            emergencyPhone: emergencyPhone
        ) {
            alertManager.showValidationError(error.localizedDescription)
            return
        }

        // Check jersey number uniqueness
        if !ValidationHelper.isJerseyNumberUnique(cleanJerseyNumber, for: team, in: modelContext) {
            alertManager.showValidationError(AppConstants.ErrorMessages.duplicateJersey)
            return
        }

        // Save the player
        savePlayer()
    }

    private func savePlayer() {
        isLoading = true

        Task {
            await MainActor.run {
                let player = Player(
                    firstName: ValidationHelper.sanitizeInput(firstName),
                    lastName: ValidationHelper.sanitizeInput(lastName),
                    jerseyNumber: ValidationHelper.sanitizeInput(jerseyNumber),
                    position: position,
                    graduationYear: graduationYear,
                    parentName: ValidationHelper.sanitizeInput(parentName),
                    parentEmail: ValidationHelper.sanitizeInput(parentEmail),
                    parentPhone: parentPhone,
                    emergencyContact: ValidationHelper.sanitizeInput(emergencyContact),
                    emergencyPhone: emergencyPhone
                )

                player.height = height.isEmpty ? nil : ValidationHelper.sanitizeInput(height)
                player.birthDate = birthDate
                player.medicalNotes = medicalNotes.isEmpty ? nil : ValidationHelper.sanitizeInput(medicalNotes)

                // Set up bidirectional relationships
                modelContext.insert(player)

                // Update team's players array
                if team.players == nil {
                    team.players = []
                }
                team.players?.append(player)

                // Update player's teams array
                if player.teams == nil {
                    player.teams = []
                }
                player.teams?.append(team)

                // Update team's modification date
                team.updatedAt = Date()

                do {
                    try modelContext.save()
                    HapticManager.shared.saveSuccess()
                    isLoading = false

                    alertManager.showSuccess(
                        message: AppConstants.SuccessMessages.playerAdded
                    ) {
                        dismiss()
                    }
                } catch {
                    isLoading = false
                    modelContext.rollback()
                    alertManager.showError(
                        error,
                        customMessage: AppConstants.ErrorMessages.saveFailed,
                        recovery: { savePlayer() }
                    )
                }
            }
        }
    }
}