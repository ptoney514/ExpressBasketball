//
//  PlayerDetailView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData

struct PlayerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let player: Player
    @State private var isEditing = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PlayerHeaderSection(player: player)

                    PlayerInfoSection(player: player)

                    ParentInfoSection(player: player)

                    EmergencyInfoSection(player: player)

                    if let medicalNotes = player.medicalNotes, !medicalNotes.isEmpty {
                        MedicalNotesSection(notes: medicalNotes)
                    }
                }
                .padding()
            }
            .navigationTitle("Player Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { isEditing = true }) {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Delete Player", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deletePlayer()
                }
            } message: {
                Text("Are you sure you want to delete \(player.fullName)? This action cannot be undone.")
            }
        }
    }

    private func deletePlayer() {
        modelContext.delete(player)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting player: \(error)")
        }
    }
}

struct PlayerHeaderSection: View {
    let player: Player

    var body: some View {
        HStack {
            VStack {
                Text(player.jerseyNumber)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                Text("Jersey")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100)

            VStack(alignment: .leading, spacing: 8) {
                Text(player.fullName)
                    .font(.title2)
                    .bold()

                HStack {
                    Label(player.position, systemImage: "figure.basketball")
                    Text("•")
                    Text("Grade \(player.grade)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                if let height = player.height {
                    Text("Height: \(height)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PlayerInfoSection: View {
    let player: Player

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Player Information")
                .font(.headline)

            if let birthDate = player.birthDate {
                InfoRow(label: "Birth Date", value: birthDate.formatted(date: .abbreviated, time: .omitted))
            }

            InfoRow(label: "Status", value: player.isActive ? "Active" : "Inactive")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ParentInfoSection: View {
    let player: Player

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parent/Guardian")
                .font(.headline)

            InfoRow(label: "Name", value: player.parentName)
            InfoRow(label: "Email", value: player.parentEmail)
            InfoRow(label: "Phone", value: player.parentPhone)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EmergencyInfoSection: View {
    let player: Player

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emergency Contact")
                .font(.headline)

            InfoRow(label: "Name", value: player.emergencyContact)
            InfoRow(label: "Phone", value: player.emergencyPhone)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MedicalNotesSection: View {
    let notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Medical Notes")
                .font(.headline)

            Text(notes)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}