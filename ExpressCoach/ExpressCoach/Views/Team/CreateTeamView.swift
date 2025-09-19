//
//  CreateTeamView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData

struct CreateTeamView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var teamName = ""
    @State private var ageGroup = "U10"
    @State private var coachName = ""
    @State private var primaryColor = Color.blue
    @State private var secondaryColor = Color.white

    let ageGroups = ["U8", "U10", "U12", "U14", "U16", "U18", "Varsity", "JV"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Team Information") {
                    TextField("Team Name", text: $teamName)

                    Picker("Age Group", selection: $ageGroup) {
                        ForEach(ageGroups, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }

                    TextField("Head Coach Name", text: $coachName)
                }

                Section("Team Colors") {
                    ColorPicker("Primary Color", selection: $primaryColor)
                    ColorPicker("Secondary Color", selection: $secondaryColor)
                }

                Section {
                    Text("A unique team code will be generated automatically")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Create Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createTeam()
                    }
                    .bold()
                    .disabled(teamName.isEmpty || coachName.isEmpty)
                }
            }
        }
    }

    private func createTeam() {
        let team = Team(
            name: teamName,
            ageGroup: ageGroup,
            coachName: coachName,
            primaryColor: primaryColor.toHexString(),
            secondaryColor: secondaryColor.toHexString()
        )

        modelContext.insert(team)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving team: \(error)")
        }
    }
}

extension Color {
    func toHexString() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
        return String(format: "#%06x", rgb)
    }
}