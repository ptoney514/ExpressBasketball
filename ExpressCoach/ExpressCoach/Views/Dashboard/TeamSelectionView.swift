//
//  TeamSelectionView.swift
//  ExpressCoach
//
//  View for selecting or entering a team code
//

import SwiftUI
import SwiftData

struct TeamSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var teams: [Team]
    @State private var teamCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var selectedTeam: Team?
    @State private var supabaseTeams: [SupabaseTeam] = []
    @State private var showingDemoConfirmation = false
    @State private var showingOnboarding = false
    @State private var showDemoTeams = false

    private let supabaseManager = SupabaseManager.shared
    private let demoDataManager = DemoDataManager.shared

    // Demo teams for preview/offline mode
    private var demoTeams: [SupabaseTeam] {
        [
            SupabaseTeam(
                id: UUID(),
                clubId: nil,
                name: "Thunder Elite",
                ageGroup: "U12 Boys",
                teamCode: "DEMO01",
                coachId: nil,
                practiceLocation: "Main Gym",
                practiceTime: "Tue/Thu 6:00 PM",
                homeVenue: "Express Arena",
                seasonRecord: "12-3",
                createdAt: Date(),
                updatedAt: Date(),
                coach: SupabaseCoach(
                    id: UUID(),
                    firstName: "Mike",
                    lastName: "Johnson",
                    email: "coach@demo.com",
                    phone: "555-0101",
                    role: "Head Coach"
                )
            ),
            SupabaseTeam(
                id: UUID(),
                clubId: nil,
                name: "Lightning Squad",
                ageGroup: "U14 Girls",
                teamCode: "DEMO02",
                coachId: nil,
                practiceLocation: "West Court",
                practiceTime: "Mon/Wed 7:00 PM",
                homeVenue: "Express Arena",
                seasonRecord: "10-5",
                createdAt: Date(),
                updatedAt: Date(),
                coach: SupabaseCoach(
                    id: UUID(),
                    firstName: "Sarah",
                    lastName: "Williams",
                    email: "coach2@demo.com",
                    phone: "555-0102",
                    role: "Head Coach"
                )
            ),
            SupabaseTeam(
                id: UUID(),
                clubId: nil,
                name: "Express Warriors",
                ageGroup: "U16 Boys",
                teamCode: "DEMO03",
                coachId: nil,
                practiceLocation: "Arena B",
                practiceTime: "Wed/Fri 5:30 PM",
                homeVenue: "Express Arena",
                seasonRecord: "15-2",
                createdAt: Date(),
                updatedAt: Date(),
                coach: SupabaseCoach(
                    id: UUID(),
                    firstName: "James",
                    lastName: "Davis",
                    email: "coach3@demo.com",
                    phone: "555-0103",
                    role: "Head Coach"
                )
            )
        ]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Image(systemName: "basketball.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color("BasketballOrange"))
                    .padding(.top, 50)

                Text("Welcome to Express Coach")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Select your team to get started")
                    .font(.headline)
                    .foregroundColor(.gray)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("BasketballOrange")))
                        .scaleEffect(1.5)
                        .padding()
                } else {
                    VStack(spacing: 20) {
                        // Team code entry
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Enter Team Code")
                                .font(.headline)
                                .foregroundColor(.white)

                            HStack {
                                TextField("e.g., EU4FOS", text: $teamCode)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.allCharacters)
                                    .disableAutocorrection(true)

                                Button(action: loadTeamByCode) {
                                    Text("Join")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color("BasketballOrange"))
                                        .cornerRadius(8)
                                }
                                .disabled(teamCode.count != 6)
                            }
                        }
                        .padding()

                        Divider()
                            .background(Color.gray)

                        // Available teams list
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Available Teams")
                                .font(.headline)
                                .foregroundColor(.white)

                            ScrollView {
                                VStack(spacing: 10) {
                                    let teamsToShow = showDemoTeams ? demoTeams : supabaseTeams

                                    if teamsToShow.isEmpty && !showDemoTeams {
                                        // Show demo teams hint when no teams loaded
                                        VStack(spacing: 15) {
                                            Image(systemName: "wifi.slash")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)

                                            Text("Can't connect to server")
                                                .font(.headline)
                                                .foregroundColor(.gray)

                                            Button(action: {
                                                withAnimation {
                                                    showDemoTeams = true
                                                    errorMessage = ""
                                                }
                                            }) {
                                                Label("View Demo Teams", systemImage: "play.circle")
                                                    .font(.callout)
                                                    .foregroundColor(Color("BasketballOrange"))
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 30)
                                    } else {
                                        ForEach(teamsToShow, id: \.id) { team in
                                            TeamSelectionCard(team: team) {
                                                if showDemoTeams {
                                                    // For demo teams, activate demo mode
                                                    showingDemoConfirmation = true
                                                } else {
                                                    selectSupabaseTeam(team)
                                                }
                                            }
                                        }

                                        if showDemoTeams {
                                            Text("Demo teams - tap to preview")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .frame(maxWidth: .infinity)
                                                .padding(.top, 10)
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 300)
                        }
                        .padding()
                    }
                }

                if !errorMessage.isEmpty && !showDemoTeams {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()

                // Demo Mode Button
                Button(action: { showingDemoConfirmation = true }) {
                    Label("Try Demo Mode", systemImage: "play.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(
                            colors: [Color("BasketballOrange"), Color.orange.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("BackgroundDark"))
            .onAppear {
                loadAvailableTeams()
            }
            .fullScreenCover(item: $selectedTeam) { team in
                MainTabView()
            }
            .confirmationDialog("Enable Demo Mode", isPresented: $showingDemoConfirmation, titleVisibility: .visible) {
                Button("Start Demo") {
                    showingOnboarding = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will create sample teams and players for demonstration purposes. You can switch to live data later in settings.")
            }
            .fullScreenCover(isPresented: $showingOnboarding, onDismiss: {
                activateDemoMode()
            }) {
                OnboardingView()
            }
        }
    }

    private func loadAvailableTeams() {
        isLoading = true
        errorMessage = ""
        showDemoTeams = false

        Task {
            do {
                let teams = try await supabaseManager.fetchTeams()
                await MainActor.run {
                    self.supabaseTeams = teams
                    self.isLoading = false
                    // If we got teams, hide demo teams
                    if !teams.isEmpty {
                        self.showDemoTeams = false
                    }
                }
            } catch {
                await MainActor.run {
                    // On error, show demo teams as fallback
                    self.showDemoTeams = true
                    self.supabaseTeams = []
                    self.errorMessage = ""
                    self.isLoading = false
                }
            }
        }
    }

    private func loadTeamByCode() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                if let team = try await supabaseManager.fetchTeam(byCode: teamCode.uppercased()) {
                    await MainActor.run {
                        createLocalTeam(from: team)
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "No team found with code: \(teamCode)"
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load team: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    private func selectSupabaseTeam(_ supabaseTeam: SupabaseTeam) {
        createLocalTeam(from: supabaseTeam)
    }

    private func createLocalTeam(from supabaseTeam: SupabaseTeam) {
        // Create local SwiftData team from Supabase team
        let team = Team(
            name: supabaseTeam.name,
            ageGroup: supabaseTeam.ageGroup,
            coachName: supabaseTeam.coach?.firstName ?? "Coach"
        )

        // Set the team code manually
        team.teamCode = supabaseTeam.teamCode

        // Set practice location and time if available
        if let location = supabaseTeam.practiceLocation {
            team.practiceLocation = location
        }
        if let time = supabaseTeam.practiceTime {
            team.practiceTime = time
        }

        modelContext.insert(team)

        // Save the context
        do {
            try modelContext.save()
            selectedTeam = team
        } catch {
            errorMessage = "Failed to save team: \(error.localizedDescription)"
        }
    }

    private func activateDemoMode() {
        isLoading = true
        errorMessage = ""

        Task {
            await MainActor.run {
                do {
                    // Set demo mode flag
                    demoDataManager.setDemoMode(true)

                    // Seed demo data
                    try demoDataManager.seedDemoData(in: modelContext)

                    // Fetch the first demo team to select it
                    let descriptor = FetchDescriptor<Team>(
                        predicate: #Predicate { team in
                            team.teamCode == "DEMO01"
                        }
                    )
                    let demoTeams = try modelContext.fetch(descriptor)

                    if let firstTeam = demoTeams.first {
                        selectedTeam = firstTeam
                    }

                    isLoading = false
                } catch {
                    errorMessage = "Failed to create demo data: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

struct TeamSelectionCard: View {
    let team: SupabaseTeam
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(team.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack {
                        Label(team.ageGroup, systemImage: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.gray)

                        if let coach = team.coach {
                            Label("\(coach.firstName) \(coach.lastName)", systemImage: "person.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    if let location = team.practiceLocation, let time = team.practiceTime {
                        Label("\(location) - \(time)", systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(Color("BasketballOrange"))
                    }
                }

                Spacer()

                VStack {
                    Text(team.teamCode)
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(Color("BasketballOrange"))

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

#Preview {
    TeamSelectionView()
        .modelContainer(for: Team.self, inMemory: true)
}