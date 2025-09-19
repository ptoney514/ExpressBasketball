//
//  SettingsView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var teams: [Team]

    var currentTeam: Team? {
        teams.first
    }

    var body: some View {
        NavigationStack {
            List {
                if let team = currentTeam {
                    Section("Team") {
                        TeamCodeRow(team: team)

                        NavigationLink(destination: Text("Edit Team")) {
                            Label("Edit Team Info", systemImage: "pencil")
                        }

                        NavigationLink(destination: Text("Assistant Coaches")) {
                            Label("Manage Coaches", systemImage: "person.2")
                        }
                    }

                    Section("Data Management") {
                        NavigationLink(destination: Text("Export Data")) {
                            Label("Export Team Data", systemImage: "square.and.arrow.up")
                        }

                        NavigationLink(destination: Text("Import Data")) {
                            Label("Import Data", systemImage: "square.and.arrow.down")
                        }
                    }
                }

                Section("App") {
                    NavigationLink(destination: Text("Notifications")) {
                        Label("Notifications", systemImage: "bell")
                    }

                    NavigationLink(destination: Text("Privacy")) {
                        Label("Privacy & Security", systemImage: "lock")
                    }

                    NavigationLink(destination: Text("About")) {
                        Label("About", systemImage: "info.circle")
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct TeamCodeRow: View {
    let team: Team
    @State private var showingQRCode = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Team Code")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(team.teamCode)
                    .font(.title2)
                    .monospaced()
                    .bold()
            }

            Spacer()

            Button(action: { showingQRCode = true }) {
                Image(systemName: "qrcode")
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingQRCode) {
            TeamQRCodeView(team: team)
        }
    }
}

struct TeamQRCodeView: View {
    let team: Team
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Team Code")
                    .font(.title)
                    .bold()

                Text(team.teamCode)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)

                Image(systemName: "qrcode")
                    .font(.system(size: 200))
                    .foregroundColor(.black)

                Text("Parents can scan this code or enter it manually in the Express United app")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Button(action: shareCode) {
                    Label("Share Code", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Share Team Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func shareCode() {
        let message = "Join our team on Express United! Team Code: \(team.teamCode)"
        let activityController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
}