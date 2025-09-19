//
//  PlayerDetailView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct PlayerDetailView: View {
    let player: Player

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading) {
                        Text("#\(player.jerseyNumber)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(player.position)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))

                VStack(alignment: .leading, spacing: 20) {
                    GroupBox("Player Information") {
                        VStack(spacing: 12) {
                            InfoRow(label: "Name", value: player.fullName)
                            InfoRow(label: "Position", value: player.position)
                            InfoRow(label: "Jersey Number", value: player.jerseyNumber)

                            if let height = player.height {
                                InfoRow(label: "Height", value: height)
                            }

                            if let grade = player.grade {
                                InfoRow(label: "Grade", value: grade)
                            }

                            if let dob = player.dateOfBirth {
                                InfoRow(label: "Date of Birth", value: dob.formatted(date: .abbreviated, time: .omitted))
                            }
                        }
                    }

                    if player.parentName != nil || player.parentEmail != nil || player.parentPhone != nil {
                        GroupBox("Parent/Guardian Contact") {
                            VStack(spacing: 12) {
                                if let name = player.parentName {
                                    InfoRow(label: "Name", value: name)
                                }
                                if let email = player.parentEmail {
                                    InfoRow(label: "Email", value: email)
                                }
                                if let phone = player.parentPhone {
                                    InfoRow(label: "Phone", value: phone)
                                }
                            }
                        }
                    }

                    if player.emergencyContact != nil || player.emergencyPhone != nil {
                        GroupBox("Emergency Contact") {
                            VStack(spacing: 12) {
                                if let contact = player.emergencyContact {
                                    InfoRow(label: "Name", value: contact)
                                }
                                if let phone = player.emergencyPhone {
                                    InfoRow(label: "Phone", value: phone)
                                }
                            }
                        }
                    }

                    if let notes = player.medicalNotes, !notes.isEmpty {
                        GroupBox("Medical Notes") {
                            Text(notes)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(player.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.body)
            Spacer()
        }
    }
}