//
//  ProfileView.swift
//  ExpressCoach
//
//  Created on 9/21/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var teams: [Team]
    @Environment(\.modelContext) private var modelContext
    @State private var showingSettings = false
    @State private var showingEditProfile = false
    @State private var coachName = "Coach"
    @State private var coachTitle = "Head Coach"
    @State private var coachBio = ""
    @State private var yearsCoaching = 5

    @AppStorage("isDemoMode") private var isDemoMode = false

    var currentTeam: Team? {
        teams.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color("BackgroundDark")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Profile Header
                        profileHeaderSection

                        // Stats Cards
                        statsSection
                            .padding(.horizontal)
                            .padding(.top, -40)

                        // Teams Section
                        teamsSection
                            .padding(.horizontal)
                            .padding(.top, 20)

                        // Quick Actions
                        quickActionsSection
                            .padding(.horizontal)
                            .padding(.top, 20)

                        // About Section
                        aboutSection
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color("BasketballOrange"))
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(
                    coachName: $coachName,
                    coachTitle: $coachTitle,
                    coachBio: $coachBio,
                    yearsCoaching: $yearsCoaching
                )
            }
            .onAppear {
                loadProfileData()
            }
        }
    }

    // MARK: - View Components

    private var profileHeaderSection: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BasketballOrange").opacity(0.8),
                    Color("BasketballOrange").opacity(0.3),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 16) {
                // Profile Image
                ZStack {
                    Circle()
                        .fill(Color("CoachBlack"))
                        .frame(width: 100, height: 100)

                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color("BasketballOrange"))
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )

                // Name and Title
                VStack(spacing: 4) {
                    Text(coachName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(coachTitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }

                // Edit Profile Button
                Button(action: { showingEditProfile = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.caption)
                        Text("Edit Profile")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                }
            }
            .padding(.bottom, 60)
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            ProfileStatCard(
                icon: "person.3.fill",
                value: "\(teams.flatMap { $0.players ?? [] }.count)",
                label: "Players"
            )

            ProfileStatCard(
                icon: "sportscourt.fill",
                value: "\(teams.count)",
                label: "Teams"
            )

            ProfileStatCard(
                icon: "calendar",
                value: "\(upcomingEventsCount)",
                label: "This Week"
            )

            ProfileStatCard(
                icon: "trophy.fill",
                value: "12-3",
                label: "Record"
            )
        }
    }

    private var teamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("My Teams", systemImage: "sportscourt.fill")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if teams.count > 1 {
                    NavigationLink(destination: Text("All Teams").preferredColorScheme(.dark)) {
                        Text("See All")
                            .font(.caption)
                            .foregroundColor(Color("BasketballOrange"))
                    }
                }
            }

            ForEach(teams.prefix(3)) { team in
                ProfileTeamCard(team: team)
            }

            if teams.isEmpty {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color("BasketballOrange"))
                    Text("Join or create a team")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                .background(Color("CoachBlack"))
                .cornerRadius(12)
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Quick Actions", systemImage: "bolt.fill")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "qrcode",
                    title: "Share Code",
                    color: Color("BasketballOrange")
                ) {
                    // TODO: Show team code sharing
                }

                QuickActionButton(
                    icon: "square.and.arrow.up",
                    title: "Export",
                    color: Color.blue
                ) {
                    // TODO: Export data
                }

                QuickActionButton(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Analytics",
                    color: Color.green
                ) {
                    // TODO: Show analytics
                }
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("About", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 16) {
                if !coachBio.isEmpty {
                    Text(coachBio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(Color("BasketballOrange"))
                        .font(.caption)
                    Text("\(yearsCoaching) years coaching experience")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(Color("BasketballOrange"))
                        .font(.caption)
                    Text("coach@expressbasketball.com")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                if isDemoMode {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(Color("BasketballOrange"))
                            .font(.caption)
                        Text("Demo Mode Active")
                            .font(.caption)
                            .foregroundColor(Color("BasketballOrange"))
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("CoachBlack"))
            .cornerRadius(12)
        }
    }

    // MARK: - Helper Properties

    private var upcomingEventsCount: Int {
        let calendar = Calendar.current
        let weekFromNow = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()

        return teams.flatMap { team in
            (team.schedules ?? []).filter { schedule in
                schedule.date >= Date() && schedule.date <= weekFromNow
            }
        }.count
    }

    // MARK: - Methods

    private func loadProfileData() {
        if let team = currentTeam {
            coachName = team.coachName
            // Load other profile data from team or user defaults
        }
    }
}

// MARK: - Supporting Views

struct ProfileStatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("BasketballOrange"))

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color("CoachBlack"))
        .cornerRadius(12)
    }
}

struct ProfileTeamCard: View {
    let team: Team

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    Label("\(team.players?.count ?? 0) players", systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Label("Code: \(team.teamCode)", systemImage: "number")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color("CoachBlack"))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color("CoachBlack"))
            .cornerRadius(12)
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Binding var coachName: String
    @Binding var coachTitle: String
    @Binding var coachBio: String
    @Binding var yearsCoaching: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()

                Form {
                    Section("Profile Information") {
                        HStack {
                            Text("Name")
                                .foregroundColor(.gray)
                            TextField("Coach Name", text: $coachName)
                                .multilineTextAlignment(.trailing)
                        }

                        HStack {
                            Text("Title")
                                .foregroundColor(.gray)
                            TextField("Title", text: $coachTitle)
                                .multilineTextAlignment(.trailing)
                        }

                        VStack(alignment: .leading) {
                            Text("Bio")
                                .foregroundColor(.gray)
                            TextEditor(text: $coachBio)
                                .frame(minHeight: 100)
                        }
                    }
                    .listRowBackground(Color("CoachBlack"))

                    Section("Experience") {
                        Stepper(value: $yearsCoaching, in: 0...50) {
                            HStack {
                                Text("Years Coaching")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(yearsCoaching)")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .listRowBackground(Color("CoachBlack"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("BasketballOrange"))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                    .foregroundColor(Color("BasketballOrange"))
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveProfile() {
        // TODO: Save profile data to database or user defaults
        print("Profile saved: \(coachName), \(coachTitle)")
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [Team.self, Player.self, Schedule.self])
}