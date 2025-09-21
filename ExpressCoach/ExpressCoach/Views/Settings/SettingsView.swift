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
    @Environment(\.modelContext) private var modelContext
    @State private var selectedCoachRole: CoachRole = .headCoach
    @State private var showingRoleInfo = false
    @State private var showingClearDataConfirmation = false
    @State private var showingSwitchToLiveMode = false
    @State private var showingOnboarding = false
    @State private var isDemoMode: Bool = false
    @State private var showingEnableDemoMode = false

    private let demoDataManager = DemoDataManager.shared

    var currentTeam: Team? {
        teams.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()

                List {
                    // Coach Profile Section
                    Section {
                        CoachProfileCard(
                            team: currentTeam,
                            selectedRole: $selectedCoachRole,
                            showingRoleInfo: $showingRoleInfo
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                    if let team = currentTeam {
                        Section("Team Management") {
                            TeamCodeRow(team: team)

                            NavigationLink(destination: Text("Edit Team").preferredColorScheme(.dark)) {
                                Label("Edit Team Info", systemImage: "pencil")
                                    .foregroundColor(.white)
                            }

                            NavigationLink(destination: Text("Assistant Coaches").preferredColorScheme(.dark)) {
                                Label("Manage Coaches", systemImage: "person.2")
                                    .foregroundColor(.white)
                            }
                        }
                        .listRowBackground(Color("CoachBlack"))

                        Section("Data Management") {
                            NavigationLink(destination: Text("Export Data").preferredColorScheme(.dark)) {
                                Label("Export Team Data", systemImage: "square.and.arrow.up")
                                    .foregroundColor(.white)
                            }

                            NavigationLink(destination: Text("Import Data").preferredColorScheme(.dark)) {
                                Label("Import Data", systemImage: "square.and.arrow.down")
                                    .foregroundColor(.white)
                            }
                        }
                        .listRowBackground(Color("CoachBlack"))
                    }

                    // Demo Mode Section (always visible)
                    Section("Demo Mode") {
                        Toggle(isOn: $isDemoMode) {
                            Label("Demo Mode", systemImage: isDemoMode ? "play.circle.fill" : "play.circle")
                                .foregroundColor(isDemoMode ? Color("BasketballOrange") : .white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color("BasketballOrange")))
                        .onChange(of: isDemoMode) { oldValue, newValue in
                            if newValue {
                                showingEnableDemoMode = true
                            } else {
                                showingSwitchToLiveMode = true
                            }
                        }

                        if isDemoMode {
                            Text("Sample teams and data loaded for demonstration")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Button(action: { showingOnboarding = true }) {
                                Label("View Demo Tutorial", systemImage: "play.rectangle")
                                    .foregroundColor(.white)
                            }

                            Button(action: refreshDemoData) {
                                Label("Refresh Demo Data", systemImage: "arrow.clockwise")
                                    .foregroundColor(.white)
                            }

                            Button(action: { showingClearDataConfirmation = true }) {
                                Label("Clear All Data", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .listRowBackground(Color("CoachBlack"))

                    Section("AI & Analytics") {
                        NavigationLink(destination: AIInsightsView().preferredColorScheme(.dark)) {
                            Label("AI Performance Insights", systemImage: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.white)
                        }

                        NavigationLink(destination: Text("Communication Analytics").preferredColorScheme(.dark)) {
                            Label("Communication Analytics", systemImage: "chart.bar.xaxis")
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color("CoachBlack"))

                    Section("App Settings") {
                        NavigationLink(destination: Text("Notifications").preferredColorScheme(.dark)) {
                            Label("Notifications", systemImage: "bell")
                                .foregroundColor(.white)
                        }

                        NavigationLink(destination: Text("Privacy").preferredColorScheme(.dark)) {
                            Label("Privacy & Security", systemImage: "lock")
                                .foregroundColor(.white)
                        }

                        NavigationLink(destination: Text("About").preferredColorScheme(.dark)) {
                            Label("About", systemImage: "info.circle")
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color("CoachBlack"))

                    Section {
                        HStack {
                            Spacer()
                            Text("Express Coach v1.0.0")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showingRoleInfo) {
                CoachRoleInfoView()
            }
            .confirmationDialog("Clear All Data", isPresented: $showingClearDataConfirmation, titleVisibility: .visible) {
                Button("Clear All Data", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all teams, players, schedules, and announcements. This action cannot be undone.")
            }
            .confirmationDialog("Switch to Live Mode", isPresented: $showingSwitchToLiveMode, titleVisibility: .visible) {
                Button("Switch to Live Mode") {
                    switchToLiveMode()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear demo data and allow you to connect to live teams. You'll need to enter a team code or select from available teams.")
            }
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingView(onComplete: {
                    showingOnboarding = false
                })
            }
            .confirmationDialog("Enable Demo Mode", isPresented: $showingEnableDemoMode, titleVisibility: .visible) {
                Button("Enable Demo Mode") {
                    enableDemoMode()
                }
                Button("Cancel", role: .cancel) {
                    isDemoMode = false
                }
            } message: {
                Text("This will create sample teams and players for demonstration. Any existing data will be preserved.")
            }
            .onAppear {
                isDemoMode = demoDataManager.isDemoMode()
            }
        }
    }

    // MARK: - Private Methods

    private func clearAllData() {
        do {
            try demoDataManager.clearAllData(in: modelContext)
            demoDataManager.setDemoMode(false)
        } catch {
            print("Failed to clear data: \(error)")
        }
    }

    private func switchToLiveMode() {
        do {
            // Clear only demo teams, not all data
            let descriptor = FetchDescriptor<Team>(
                predicate: #Predicate { team in
                    team.teamCode == "DEMO01" || team.teamCode == "DEMO02"
                }
            )
            let demoTeams = try modelContext.fetch(descriptor)
            for team in demoTeams {
                modelContext.delete(team)
            }
            try modelContext.save()

            demoDataManager.setDemoMode(false)
            isDemoMode = false
        } catch {
            print("Failed to switch to live mode: \(error)")
        }
    }

    private func enableDemoMode() {
        do {
            demoDataManager.setDemoMode(true)
            try demoDataManager.seedDemoData(in: modelContext)
            isDemoMode = true
        } catch {
            print("Failed to enable demo mode: \(error)")
            isDemoMode = false
        }
    }

    private func refreshDemoData() {
        do {
            // Clear existing demo data
            let descriptor = FetchDescriptor<Team>(
                predicate: #Predicate { team in
                    team.teamCode == "DEMO01" || team.teamCode == "DEMO02"
                }
            )
            let existingDemoTeams = try modelContext.fetch(descriptor)
            for team in existingDemoTeams {
                modelContext.delete(team)
            }
            try modelContext.save()

            // Re-seed demo data
            try demoDataManager.seedDemoData(in: modelContext)
        } catch {
            print("Failed to refresh demo data: \(error)")
        }
    }
}

// Coach Profile Card Component
struct CoachProfileCard: View {
    let team: Team?
    @Binding var selectedRole: CoachRole
    @Binding var showingRoleInfo: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Coach info header
            HStack {
                ZStack {
                    Circle()
                        .fill(Color("BasketballOrange"))
                        .frame(width: 50, height: 50)

                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(team?.coachName ?? "Coach")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(team?.name ?? "No Team Selected")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: { showingRoleInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(Color("BasketballOrange"))
                }
            }

            Divider()
                .background(.gray.opacity(0.3))

            // Role selector
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Coach Role")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)

                    Spacer()
                }

                Picker("Coach Role", selection: $selectedRole) {
                    ForEach(CoachRole.allCases, id: \.self) { role in
                        Text(role.displayName).tag(role)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedRole) { oldValue, newValue in
                    updateTeamRole(newValue)
                }
            }

            // Role permissions
            if selectedRole != .headCoach {
                HStack {
                    Image(systemName: selectedRole == .director ? "crown.fill" : "person.badge.key.fill")
                        .foregroundColor(Color("BasketballOrange"))
                        .font(.caption)

                    Text(selectedRole == .director ? "Can manage all teams" : "Assists head coach")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()
                }
            }
        }
        .padding()
        .background(Color("BackgroundDark"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("BasketballOrange").opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .padding()
        .onAppear {
            selectedRole = team?.coachRole ?? .headCoach
        }
    }

    private func updateTeamRole(_ newRole: CoachRole) {
        // TODO: Update team role in database
        print("Updated coach role to: \(newRole.displayName)")
    }
}

struct TeamCodeRow: View {
    let team: Team
    @State private var showingQRCode = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Team Code")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(team.teamCode)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("BasketballOrange"))
                    .monospaced()
            }

            Spacer()

            Button(action: { showingQRCode = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "qrcode")
                        .font(.title3)
                    Text("Share")
                        .font(.caption)
                }
                .foregroundColor(Color("BasketballOrange"))
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
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Image(systemName: "sportscourt.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color("BasketballOrange"))

                        Text("Team Access Code")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(team.name)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    VStack(spacing: 12) {
                        Text(team.teamCode)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(Color("BasketballOrange"))
                            .padding()
                            .background(Color("CoachBlack"))
                            .cornerRadius(12)

                        // QR Code placeholder (would need actual QR generation)
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                                .frame(width: 200, height: 200)

                            Image(systemName: "qrcode")
                                .font(.system(size: 160))
                                .foregroundColor(.black)
                        }
                    }

                    Text("Parents can scan this code or enter it manually in the Express United app to follow your team")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    Button(action: shareCode) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                            Text("Share Team Code")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("BasketballOrange"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                }
                .padding()
            }
            .navigationTitle("Share Team Code")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("BasketballOrange"))
                }
            }
        }
    }

    private func shareCode() {
        let message = "🏀 Join our team \(team.name) on Express United!\n\nTeam Code: \(team.teamCode)\n\nDownload Express United from the App Store to stay updated with practices, games, and announcements!"
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

// Coach Role Information View
struct CoachRoleInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Image(systemName: "person.badge.key.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color("BasketballOrange"))

                            Text("Coach Roles")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Different roles have different permissions and capabilities")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: 16) {
                            RoleInfoCard(
                                role: .headCoach,
                                description: "Full team management including roster, schedule, and all communications",
                                permissions: ["Manage players", "Create schedules", "Send notifications", "View all data"]
                            )

                            RoleInfoCard(
                                role: .assistantCoach,
                                description: "Assist head coach with limited management capabilities",
                                permissions: ["View roster", "Send notifications", "View schedules", "Limited editing"]
                            )

                            RoleInfoCard(
                                role: .director,
                                description: "Organization-wide oversight with access to all teams",
                                permissions: ["Manage all teams", "Organization analytics", "Coach management", "Full access"]
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Role Information")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("BasketballOrange"))
                }
            }
        }
    }
}

struct RoleInfoCard: View {
    let role: CoachRole
    let description: String
    let permissions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: roleIcon)
                    .font(.title2)
                    .foregroundColor(Color("BasketballOrange"))

                Text(role.displayName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 6) {
                Text("Permissions:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                ForEach(permissions, id: \.self) { permission in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(Color("CourtGreen"))

                        Text(permission)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color("CoachBlack"))
        .cornerRadius(12)
    }

    private var roleIcon: String {
        switch role {
        case .headCoach:
            return "person.fill.badge.plus"
        case .assistantCoach:
            return "person.badge.key.fill"
        case .director:
            return "crown.fill"
        }
    }
}
