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

    let team: Team

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var jerseyNumber = ""
    @State private var position = "Guard"
    @State private var graduationYear = Calendar.current.component(.year, from: Date()) + 6
    @State private var height = ""
    @State private var birthDate = Date()

    @State private var parentName = ""
    @State private var parentEmail = ""
    @State private var parentPhone = ""
    @State private var emergencyContact = ""
    @State private var emergencyPhone = ""
    @State private var medicalNotes = ""

    let positions = ["Guard", "Forward", "Center", "Point Guard", "Shooting Guard", "Small Forward", "Power Forward"]
    let currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        NavigationStack {
            Form {
                Section("Player Information") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Jersey Number", text: $jerseyNumber)
                        .keyboardType(.numberPad)

                    Picker("Position", selection: $position) {
                        ForEach(positions, id: \.self) { position in
                            Text(position).tag(position)
                        }
                    }

                    Picker("Graduation Year", selection: $graduationYear) {
                        ForEach((currentYear...(currentYear + 15)), id: \.self) { year in
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
                    TextField("Email", text: $parentEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone Number", text: $parentPhone)
                        .keyboardType(.phonePad)
                }

                Section("Emergency Contact") {
                    TextField("Emergency Contact Name", text: $emergencyContact)
                    TextField("Emergency Phone", text: $emergencyPhone)
                        .keyboardType(.phonePad)
                }

                Section("Medical Information") {
                    TextField("Medical Notes (optional)", text: $medicalNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePlayer()
                    }
                    .bold()
                    .disabled(!isFormValid)
                }
            }
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

    private func savePlayer() {
        let player = Player(
            firstName: firstName,
            lastName: lastName,
            jerseyNumber: jerseyNumber,
            position: position,
            graduationYear: graduationYear,
            parentName: parentName,
            parentEmail: parentEmail,
            parentPhone: parentPhone,
            emergencyContact: emergencyContact,
            emergencyPhone: emergencyPhone
        )

        player.height = height.isEmpty ? nil : height
        player.birthDate = birthDate
        player.medicalNotes = medicalNotes.isEmpty ? nil : medicalNotes

        // Initialize teams array and add current team
        if player.teams == nil {
            player.teams = []
        }
        player.teams?.append(team)

        modelContext.insert(player)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving player: \(error)")
        }
    }
}