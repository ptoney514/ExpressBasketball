//
//  EditPlayerView.swift
//  ExpressCoach
//
//  Edit existing player information
//

import SwiftUI
import SwiftData

struct EditPlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var jerseyNumber: String = ""
    @State private var position: String = "Guard"
    @State private var graduationYear: Int = Calendar.current.component(.year, from: Date()) + 6
    @State private var height: String = ""
    @State private var birthDate: Date = Date()
    @State private var showBirthDate: Bool = false

    @State private var parentName: String = ""
    @State private var parentEmail: String = ""
    @State private var parentPhone: String = ""
    @State private var emergencyContact: String = ""
    @State private var emergencyPhone: String = ""
    @State private var medicalNotes: String = ""

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

                    if showBirthDate {
                        DatePicker("Birth Date",
                                  selection: $birthDate,
                                  displayedComponents: .date)
                    }
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
            .navigationTitle("Edit Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .bold()
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                loadPlayerData()
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

    private func loadPlayerData() {
        firstName = player.firstName
        lastName = player.lastName
        jerseyNumber = player.jerseyNumber
        position = player.position
        graduationYear = player.graduationYear
        height = player.height ?? ""

        if let playerBirthDate = player.birthDate {
            birthDate = playerBirthDate
            showBirthDate = true
        }

        parentName = player.parentName ?? ""
        parentEmail = player.parentEmail ?? ""
        parentPhone = player.parentPhone ?? ""
        emergencyContact = player.emergencyContact ?? ""
        emergencyPhone = player.emergencyPhone ?? ""
        medicalNotes = player.medicalNotes ?? ""
    }

    private func saveChanges() {
        player.firstName = firstName
        player.lastName = lastName
        player.jerseyNumber = jerseyNumber
        player.position = position
        player.graduationYear = graduationYear
        player.height = height.isEmpty ? nil : height
        player.birthDate = showBirthDate ? birthDate : nil

        player.parentName = parentName
        player.parentEmail = parentEmail
        player.parentPhone = parentPhone
        player.emergencyContact = emergencyContact
        player.emergencyPhone = emergencyPhone
        player.medicalNotes = medicalNotes.isEmpty ? nil : medicalNotes

        player.updatedAt = Date()

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving player changes: \(error)")
        }
    }
}