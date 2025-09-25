//
//  TeamDashboardView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData

struct TeamDashboardView: View {
    @Query private var teams: [Team]
    @State private var showingCreateTeam = false
    @State private var selectedTeam: Team?
    @State private var showingNotificationComposer = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()

                Group {
                    if teams.isEmpty {
                        EmptyTeamView(showingCreateTeam: $showingCreateTeam)
                    } else if let team = selectedTeam ?? teams.first {
                        TeamDetailDashboard(team: team, showingNotificationComposer: $showingNotificationComposer)
                    }
                }
            }
            .navigationTitle("Express Coach")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !teams.isEmpty {
                            Button(action: { showingNotificationComposer = true }) {
                                Image(systemName: "bell.badge")
                                    .foregroundColor(Color("BasketballOrange"))
                            }
                        }

                        Button(action: { showingCreateTeam = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(Color("BasketballOrange"))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateTeam) {
                CreateTeamView()
            }
            .sheet(isPresented: $showingNotificationComposer) {
                NotificationComposerView()
            }
        }
    }
}

struct EmptyTeamView: View {
    @Binding var showingCreateTeam: Bool

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color("BasketballOrange"))

                Text("Welcome to Express Coach")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Create your first team to start managing players, schedules, and communications")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: { showingCreateTeam = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Create Your First Team")
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

            VStack(spacing: 12) {
                Text("What you can do:")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                VStack(spacing: 8) {
                    FeatureRow(icon: "person.3.fill", text: "Manage your roster")
                    FeatureRow(icon: "calendar.circle.fill", text: "Schedule practices & games")
                    FeatureRow(icon: "bell.badge.fill", text: "Send instant notifications")
                    FeatureRow(icon: "sportscourt.fill", text: "Track game results")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundDark"))
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color("BasketballOrange"))
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

struct TeamDetailDashboard: View {
    let team: Team
    @Binding var showingNotificationComposer: Bool
    @Query private var upcomingSchedules: [Schedule]
    @State private var showingPracticeActions = false
    @State private var greeting: String = ""
    
    var nextEvent: Schedule? {
        upcomingSchedules
            .filter { $0.date > Date() }
            .sorted(by: { $0.date < $1.date })
            .first
    }
    
    var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Welcome Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(timeOfDayGreeting), Coach")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Managing \(team.name)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Hero Card - Next Event or Team Status
                if let nextEvent = nextEvent {
                    NextEventHeroCard(event: nextEvent, team: team)
                        .padding(.horizontal)
                } else {
                    TeamStatusHeroCard(team: team)
                        .padding(.horizontal)
                }
                
                // Quick Actions Grid - More prominent
                DashboardQuickActionsGrid(
                    team: team,
                    showingNotificationComposer: $showingNotificationComposer,
                    showingPracticeActions: $showingPracticeActions
                )
                .padding(.horizontal)
                
                // Communication Section
                VStack(spacing: 16) {
                    SectionHeader(title: "Communication", icon: "message.fill")
                        .padding(.horizontal)
                    
                    RecentMessagesCard(team: team)
                        .padding(.horizontal)
                }
                
                // Schedule & Team Section
                VStack(spacing: 16) {
                    SectionHeader(title: "Schedule & Team", icon: "calendar")
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        // Upcoming Events Mini Card
                        UpcomingEventsMiniCard(schedules: upcomingSchedules)
                        
                        // Team Stats Mini Card
                        TeamStatsMiniCard(team: team)
                    }
                    .padding(.horizontal)
                }
                
                // Team Overview Card
                TeamCard(team: team)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
        }
        .background(Color("BackgroundDark"))
        .actionSheet(isPresented: $showingPracticeActions) {
            ActionSheet(
                title: Text("Practice Actions"),
                message: Text("Quick actions for today's practice"),
                buttons: [
                    .default(Text("Send Practice Reminder")) {
                        showingNotificationComposer = true
                    },
                    .destructive(Text("Cancel Practice")) {
                        // TODO: Implement cancel practice
                    },
                    .default(Text("Update Location")) {
                        // TODO: Implement location update
                    },
                    .cancel()
                ]
            )
        }
    }
}

// New Quick Actions Grid - More prominent and modern
struct DashboardQuickActionsGrid: View {
    let team: Team
    @Binding var showingNotificationComposer: Bool
    @Binding var showingPracticeActions: Bool
    @State private var pressedButton: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                DashboardQuickActionCard(
                    title: "Send Message",
                    icon: "paperplane.fill",
                    gradient: [Color("BasketballOrange"), Color("BasketballOrange").opacity(0.8)],
                    isPressed: pressedButton == "message"
                ) {
                    pressedButton = "message"
                    showingNotificationComposer = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        pressedButton = nil
                    }
                }
                
                DashboardQuickActionCard(
                    title: "Quick Alert",
                    icon: "bell.badge",
                    gradient: [Color.red, Color.red.opacity(0.8)],
                    isPressed: pressedButton == "alert"
                ) {
                    pressedButton = "alert"
                    showingNotificationComposer = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        pressedButton = nil
                    }
                }
            }
            
            HStack(spacing: 12) {
                DashboardQuickActionCard(
                    title: "Add Event",
                    icon: "calendar.badge.plus",
                    gradient: [Color("CourtGreen"), Color("CourtGreen").opacity(0.8)],
                    isPressed: pressedButton == "event"
                ) {
                    pressedButton = "event"
                    // TODO: Navigate to add schedule
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        pressedButton = nil
                    }
                }
                
                DashboardQuickActionCard(
                    title: "Take Attendance",
                    icon: "checkmark.square",
                    gradient: [Color.purple, Color.purple.opacity(0.8)],
                    isPressed: pressedButton == "attendance"
                ) {
                    pressedButton = "attendance"
                    // TODO: Navigate to attendance
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        pressedButton = nil
                    }
                }
            }
        }
    }
}

struct DashboardQuickActionCard: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// New Hero Cards
struct NextEventHeroCard: View {
    let event: Schedule
    let team: Team
    
    var timeUntilEvent: String {
        let interval = event.date.timeIntervalSince(Date())
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 24 {
            let days = hours / 24
            return "in \(days) day\(days == 1 ? "" : "s")"
        } else if hours > 0 {
            return "in \(hours)h \(minutes)m"
        } else {
            return "in \(minutes) minutes"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NEXT UP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("BasketballOrange"))
                    
                    Text(event.eventType.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(timeUntilEvent)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: event.eventType == .game ? "sportscourt.fill" : "figure.basketball")
                    .font(.system(size: 40))
                    .foregroundColor(Color("BasketballOrange").opacity(0.3))
            }
            
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(event.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                }
                .foregroundColor(.gray)
                
                HStack(spacing: 6) {
                    Image(systemName: "location")
                        .font(.caption)
                    Text(event.location)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color("CoachBlack"), Color("BackgroundDark")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("BasketballOrange").opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct TeamStatusHeroCard: View {
    let team: Team
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TEAM STATUS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("CourtGreen"))
                    
                    Text(team.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(team.players?.count ?? 0) players • \(team.seasonRecord ?? "0-0") record")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("CODE")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Text(team.teamCode)
                        .font(.system(.title2, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(Color("BasketballOrange"))
                }
            }
            
            HStack(spacing: 20) {
                Label("All players active", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(Color("CourtGreen"))
                
                Label("Schedule updated", systemImage: "calendar.circle.fill")
                    .font(.caption)
                    .foregroundColor(Color("CourtGreen"))
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color("CoachBlack"), Color("BackgroundDark")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("CourtGreen").opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct QuickStatsCard: View {
    let team: Team

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Season Overview")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text(team.seasonRecord ?? "0-0")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("CourtGreen"))
            }

            HStack(spacing: 20) {
                StatItem(title: "Games", value: "0", color: Color("BasketballOrange"))
                StatItem(title: "Wins", value: "0", color: Color("CourtGreen"))
                StatItem(title: "Practices", value: "0", color: Color.blue)
                StatItem(title: "Players", value: "\(team.players?.count ?? 0)", color: Color.purple)
            }
        }
        .padding()
        .background(Color("BackgroundDark"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// New Mini Cards for better layout
struct UpcomingEventsMiniCard: View {
    let schedules: [Schedule]
    
    var upcomingEvents: [Schedule] {
        schedules
            .filter { $0.date > Date() }
            .sorted(by: { $0.date < $1.date })
            .prefix(2)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(Color("BasketballOrange"))
                Text("Upcoming")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                NavigationLink(destination: ScheduleView()) {
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(Color("BasketballOrange"))
                }
            }
            
            if upcomingEvents.isEmpty {
                VStack(spacing: 4) {
                    Image(systemName: "calendar.badge.minus")
                        .foregroundColor(.gray)
                    Text("No upcoming events")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(upcomingEvents) { event in
                        HStack {
                            Circle()
                                .fill(event.eventType == .game ? Color("BasketballOrange") : Color("CourtGreen"))
                                .frame(width: 4, height: 4)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.eventType.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("CoachBlack"))
        .cornerRadius(12)
    }
}

struct TeamStatsMiniCard: View {
    let team: Team
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar")
                    .font(.caption)
                    .foregroundColor(Color("CourtGreen"))
                Text("Team Stats")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                NavigationLink(destination: TeamRosterListView()) {
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(Color("CourtGreen"))
                }
            }
            
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(team.players?.count ?? 0)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("CourtGreen"))
                        Text("Players")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(team.seasonRecord ?? "0-0")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("BasketballOrange"))
                        Text("Record")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Label("100% Active", systemImage: "checkmark.circle")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("CoachBlack"))
        .cornerRadius(12)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color("BasketballOrange"))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

