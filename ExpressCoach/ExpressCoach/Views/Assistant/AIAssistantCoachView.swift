//
//  AIAssistantCoachView.swift
//  ExpressCoach
//
//  Created on 9/21/25.
//

import SwiftUI
import SwiftData

struct AIAssistantCoachView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var teams: [Team]
    @Query private var players: [Player]
    @Query private var schedules: [Schedule]
    @State private var showingPracticePlan = false
    @State private var showingDrills = false
    @State private var showingGamePlan = false
    @State private var showingPlayerNotifications = false

    var currentTeam: Team? {
        teams.first
    }

    var upcomingGame: Schedule? {
        schedules
            .filter { $0.eventType == .game && $0.date > Date() }
            .sorted { $0.date < $1.date }
            .first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // AI Welcome Header
                    aiHeaderSection

                    // Today's Insights
                    todaysInsightsSection

                    // Practice Planning
                    practicePlanningSection

                    // Game Strategy
                    gameStrategySection

                    // Player Management
                    playerManagementSection

                    // Weekly Drills
                    weeklyDrillsSection
                }
                .padding()
            }
            .background(Color("BackgroundDark"))
            .navigationTitle("AI Assistant Coach")
            .navigationBarTitleDisplayMode(.large)
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

    // MARK: - View Sections

    private var aiHeaderSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)

                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text("Your AI Coaching Assistant")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Personalized insights and recommendations for your team")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var todaysInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Insights")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 8) {
                InsightRow(
                    icon: "lightbulb.fill",
                    text: "Focus on defensive drills - last game showed gaps in help defense",
                    color: .yellow
                )

                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "Team shooting improved 15% over last 3 practices",
                    color: .green
                )

                InsightRow(
                    icon: "exclamationmark.triangle.fill",
                    text: "Player #23 needs extra conditioning work",
                    color: .orange
                )
            }
        }
    }

    private var practicePlanningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Practice Planning")
                .font(.headline)
                .foregroundColor(.white)

            Button(action: { showingPracticePlan = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Today's Practice Plan", systemImage: "clipboard.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Text("AI-generated 90-minute practice with focus on fundamentals")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color("CoachBlack"))
                .cornerRadius(12)
            }
            .sheet(isPresented: $showingPracticePlan) {
                PracticePlanDetailView()
            }
        }
    }

    private var gameStrategySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Strategy")
                .font(.headline)
                .foregroundColor(.white)

            if let game = upcomingGame {
                Button(action: { showingGamePlan = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Next Game Plan", systemImage: "sportscourt.fill")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Text("vs \(game.opponent ?? "Opponent") - \(game.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text("View")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("BasketballOrange"))
                    }
                    .padding()
                    .background(Color("CoachBlack"))
                    .cornerRadius(12)
                }
                .sheet(isPresented: $showingGamePlan) {
                    GamePlanDetailView(game: game)
                }
            } else {
                Text("No upcoming games scheduled")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("CoachBlack"))
                    .cornerRadius(12)
            }
        }
    }

    private var playerManagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Player Notifications")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if !playerNotifications.isEmpty {
                    Text("\(playerNotifications.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }

            if playerNotifications.isEmpty {
                Text("All players ready for next game")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("CoachBlack"))
                    .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(playerNotifications, id: \.self) { notification in
                        PlayerNotificationRow(notification: notification)
                    }
                }
            }
        }
    }

    private var weeklyDrillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Drill Recommendations")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    DrillCard(
                        title: "3-Man Weave",
                        duration: "10 min",
                        focus: "Passing",
                        color: .blue
                    )

                    DrillCard(
                        title: "Shell Defense",
                        duration: "15 min",
                        focus: "Defense",
                        color: .red
                    )

                    DrillCard(
                        title: "Free Throw Circuit",
                        duration: "10 min",
                        focus: "Shooting",
                        color: .green
                    )

                    DrillCard(
                        title: "Box Out Drill",
                        duration: "8 min",
                        focus: "Rebounding",
                        color: .purple
                    )
                }
            }
        }
    }

    // MARK: - Helper Properties

    private var playerNotifications: [String] {
        // Demo notifications - would be generated by AI analysis
        [
            "Player #12 - Absent from last practice",
            "Player #5 - Minor ankle injury, limited participation"
        ]
    }
}

// MARK: - Supporting Views

struct InsightRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(.caption)
                .foregroundColor(.white)

            Spacer()
        }
        .padding(12)
        .background(Color("CoachBlack"))
        .cornerRadius(8)
    }
}

struct PlayerNotificationRow: View {
    let notification: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)

            Text(notification)
                .font(.caption)
                .foregroundColor(.white)

            Spacer()
        }
        .padding(12)
        .background(Color("CoachBlack"))
        .cornerRadius(8)
    }
}

struct DrillCard: View {
    let title: String
    let duration: String
    let focus: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.2))
                    .frame(height: 60)

                Image(systemName: "figure.run")
                    .font(.title2)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(duration)
                    .font(.caption2)
                    .foregroundColor(.gray)

                Label(focus, systemImage: "target")
                    .font(.caption2)
                    .foregroundColor(color)
            }
        }
        .frame(width: 120)
        .padding()
        .background(Color("CoachBlack"))
        .cornerRadius(12)
    }
}

// MARK: - Detail Views (Placeholders)

struct PracticePlanDetailView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Today's Practice Plan")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Practice segments would go here
                    ForEach(practicePlanSegments, id: \.title) { segment in
                        PracticeSegmentRow(segment: segment)
                    }
                }
                .padding()
            }
            .background(Color("BackgroundDark"))
            .navigationTitle("Practice Plan")
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

    private var practicePlanSegments: [(title: String, duration: String, description: String)] {
        [
            ("Warm-up", "10 min", "Dynamic stretching and light jogging"),
            ("Ball Handling", "15 min", "Stationary and moving dribbling drills"),
            ("Shooting Practice", "20 min", "Form shooting and game-speed shots"),
            ("Team Offense", "20 min", "Work on offensive sets and plays"),
            ("Defensive Drills", "15 min", "Shell defense and closeouts"),
            ("Scrimmage", "15 min", "5v5 game situations"),
            ("Cool Down", "5 min", "Static stretching")
        ]
    }
}

struct PracticeSegmentRow: View {
    let segment: (title: String, duration: String, description: String)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(segment.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(segment.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(segment.duration)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color("BasketballOrange"))
        }
        .padding()
        .background(Color("CoachBlack"))
        .cornerRadius(8)
    }
}

struct GamePlanDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let game: Schedule

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Game Plan vs \(game.opponent ?? "Opponent")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Game plan details would go here
                    Text("AI-generated game strategy based on opponent analysis and team strengths")
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .background(Color("BackgroundDark"))
            .navigationTitle("Game Plan")
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

#Preview {
    AIAssistantCoachView()
        .modelContainer(for: [Team.self, Player.self, Schedule.self])
}