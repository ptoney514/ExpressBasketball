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
                        TeamDetailDashboard(
                            team: team,
                            teams: teams,
                            showingNotificationComposer: $showingNotificationComposer,
                            selectedTeam: $selectedTeam
                        )
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
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
    let teams: [Team]
    @Binding var showingNotificationComposer: Bool
    @Binding var selectedTeam: Team?
    @Query private var upcomingSchedules: [Schedule]
    @State private var showingPracticeActions = false
    @State private var greeting: String = ""
    @State private var scrollOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 100  // Track header height for proper spacing
    
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
        ZStack(alignment: .top) {
            // Main content with scroll detection
            ScrollViewWithOffset(offset: $scrollOffset) {
                VStack(alignment: .leading, spacing: 20) {
                    // Spacer for sticky header
                    Color.clear
                        .frame(height: headerHeight)
                    
                    // Hero Card - Next Event or Team Status
                    if let nextEvent = nextEvent {
                        NextEventHeroCard(event: nextEvent, team: team)
                            .padding(.horizontal)
                    } else {
                        TeamStatusHeroCard(team: team)
                            .padding(.horizontal)
                    }
                
                // Quick Actions Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Quick Actions")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("See all")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    DashboardQuickActionsGrid(
                        team: team,
                        showingNotificationComposer: $showingNotificationComposer,
                        showingPracticeActions: $showingPracticeActions
                    )
                    .padding(.horizontal)
                }
                
                    // Communication Section
                    VStack(spacing: 16) {
                        SectionHeader(title: "Communication", icon: "message.fill")
                            .padding(.horizontal)
                        
                        RecentMessagesCard(team: team)
                            .padding(.horizontal)
                    }
                    
                    // Teams List Section
                    TeamsListView(teams: teams, selectedTeam: $selectedTeam)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
            .background(Color("BackgroundDark"))
            
            // Sticky Header Overlay
            StickyProfileHeader(
                team: team,
                timeOfDayGreeting: timeOfDayGreeting,
                scrollOffset: scrollOffset,
                height: $headerHeight
            )
        }
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

// Uber-style compact quick actions
struct DashboardQuickActionsGrid: View {
    let team: Team
    @Binding var showingNotificationComposer: Bool
    @Binding var showingPracticeActions: Bool
    @State private var pressedButton: String? = nil
    @State private var showingAIAssistant = false
    @State private var showingChatView = false
    @State private var showingTeamsView = false

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            CompactActionButton(
                title: "Chat",
                icon: "message.fill",
                isPressed: pressedButton == "chat"
            ) {
                pressedButton = "chat"
                showingChatView = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    pressedButton = nil
                }
            }
            
            CompactActionButton(
                title: "Schedule",
                icon: "calendar",
                isPressed: pressedButton == "schedule"
            ) {
                pressedButton = "schedule"
                // TODO: Navigate to schedule
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    pressedButton = nil
                }
            }
            
            CompactActionButton(
                title: "AI Assistant",
                icon: "sparkles",
                isPressed: pressedButton == "ai"
            ) {
                pressedButton = "ai"
                showingAIAssistant = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    pressedButton = nil
                }
            }
            
            CompactActionButton(
                title: "Teams",
                icon: "person.3.fill",
                isPressed: pressedButton == "teams"
            ) {
                pressedButton = "teams"
                showingTeamsView = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    pressedButton = nil
                }
            }
        }
        .sheet(isPresented: $showingAIAssistant) {
            AIAssistantView()
        }
        .fullScreenCover(isPresented: $showingChatView) {
            NavigationStack {
                ChatView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Done") {
                                showingChatView = false
                            }
                            .foregroundColor(Color("BasketballOrange"))
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $showingTeamsView) {
            NavigationStack {
                TeamRosterListView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Done") {
                                showingTeamsView = false
                            }
                            .foregroundColor(Color("BasketballOrange"))
                        }
                    }
            }
        }
    }
}

// Compact Uber-style action button
struct CompactActionButton: View {
    let title: String
    let icon: String
    let isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.92 : 1.0)
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

// Custom ScrollView that tracks offset
struct ScrollViewWithOffset<Content: View>: View {
    @Binding var offset: CGFloat
    let content: Content
    
    init(offset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self._offset = offset
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scrollView")).minY
                    )
            }
            .frame(height: 0)
            
            content
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            offset = value
        }
    }
}

// Preference Key for scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Sticky Profile Header with animations
struct StickyProfileHeader: View {
    let team: Team
    let timeOfDayGreeting: String
    let scrollOffset: CGFloat
    @Binding var height: CGFloat
    @State private var showingProfileView = false
    @State private var showingNotifications = false
    
    // Animation calculations
    private var isCompact: Bool {
        scrollOffset < -20
    }
    
    private var headerOpacity: Double {
        // Background becomes more opaque as user scrolls
        let opacity = min(1.0, max(0.95, 1.0 - (scrollOffset / 200)))
        return opacity
    }
    
    private var scaleEffect: CGFloat {
        // Subtle scale animation
        return isCompact ? 0.95 : 1.0
    }
    
    private var verticalPadding: CGFloat {
        // Reduce padding when scrolling
        return isCompact ? 8 : 16
    }
    
    // Extract coach info (same as ProfileHeaderView)
    private var coachFirstName: String {
        team.coachName.components(separatedBy: " ").first ?? "Coach"
    }
    
    private var coachInitials: String {
        let components = team.coachName.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.count > 1 ? String(components.last?.first?.uppercased() ?? "") : ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Profile Avatar - simplified to match ExpressUnited
                Button(action: { showingProfileView = true }) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .orange.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(coachInitials)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.black)
                        )
                }
                
                // Home Title - clean and simple
                Text("Home")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Quick Actions - simplified to match ExpressUnited
                HStack(spacing: 16) {
                    // Notifications Button
                    Button(action: { showingNotifications = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)

                            // Red badge for unread notifications
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 2, y: -2)
                        }
                    }

                    // Settings Menu Button
                    Button(action: { showingProfileView = true }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                // Blurred background with dynamic opacity
                ZStack {
                    Color("BackgroundDark")
                        .opacity(headerOpacity)
                    
                    // Add blur effect for depth
                    if isCompact {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                    }
                }
                .ignoresSafeArea(edges: .top)
            )
            
            // Bottom separator line (appears when scrolling)
            if isCompact {
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .transition(.opacity)
            }
        }
        .scaleEffect(scaleEffect)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isCompact)
        .animation(.easeInOut(duration: 0.2), value: scrollOffset)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        height = geometry.size.height
                    }
                    .onChange(of: isCompact) {
                        height = geometry.size.height
                    }
            }
        )
        .fullScreenCover(isPresented: $showingProfileView) {
            ProfileView()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsListView()
        }
    }
}

