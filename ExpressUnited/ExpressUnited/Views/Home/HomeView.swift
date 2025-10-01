//
//  HomeView.swift
//  ExpressUnited
//
//  Modern parent/player dashboard inspired by ExpressCoach design
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var teams: [Team]
    @Query private var schedules: [Schedule]
    @Query private var announcements: [Announcement]

    @State private var scrollOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 100
    @State private var showingSchedule = false
    @State private var showingRoster = false
    @State private var showingAnnouncements = false

    var currentTeam: Team? {
        teams.first
    }

    var nextEvent: Schedule? {
        schedules
            .filter { $0.startTime > Date() }
            .sorted(by: { $0.startTime < $1.startTime })
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

    var parentName: String {
        // TODO: Get from user profile
        "Mike"
    }

    var parentInitials: String {
        // TODO: Get from user profile
        "MJ"
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color.black
                .ignoresSafeArea()

            // Main content
            ScrollViewWithOffset(offset: $scrollOffset) {
                VStack(alignment: .leading, spacing: 20) {
                    // Spacer for sticky header
                    Color.clear
                        .frame(height: headerHeight)

                    // Hero Card - Next Event or Team Status
                    if let nextEvent = nextEvent, let team = currentTeam {
                        NextEventHeroCard(event: nextEvent, team: team)
                            .padding(.horizontal)
                    } else if let team = currentTeam {
                        TeamStatusHeroCard(team: team)
                            .padding(.horizontal)
                    } else {
                        NoTeamHeroCard()
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

                            Text("See all")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)

                        QuickActionsGrid(
                            showingSchedule: $showingSchedule,
                            showingRoster: $showingRoster,
                            showingAnnouncements: $showingAnnouncements
                        )
                        .padding(.horizontal)
                    }

                    // Communication Section
                    if !announcements.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Communication", icon: "message.fill")
                                .padding(.horizontal)

                            RecentAnnouncementsCard(announcements: announcements)
                                .padding(.horizontal)
                        }
                    }

                    // Week Calendar Preview
                    if !schedules.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "This Week", icon: "calendar")
                                .padding(.horizontal)

                            WeekCalendarCard(schedules: schedules)
                                .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 40)
                }
            }

            // Sticky Header
            StickyParentHeader(
                greeting: timeOfDayGreeting,
                parentName: parentName,
                parentInitials: parentInitials,
                scrollOffset: scrollOffset,
                height: $headerHeight
            )
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showingSchedule) {
            NavigationStack {
                ScheduleListView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Done") {
                                showingSchedule = false
                            }
                            .foregroundColor(.orange)
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $showingRoster) {
            NavigationStack {
                RosterListView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Done") {
                                showingRoster = false
                            }
                            .foregroundColor(.orange)
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $showingAnnouncements) {
            NavigationStack {
                AnnouncementsListView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Done") {
                                showingAnnouncements = false
                            }
                            .foregroundColor(.orange)
                        }
                    }
            }
        }
    }
}

// MARK: - Quick Actions Grid

struct QuickActionsGrid: View {
    @Binding var showingSchedule: Bool
    @Binding var showingRoster: Bool
    @Binding var showingAnnouncements: Bool

    @State private var pressedButton: String? = nil

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            CompactActionButton(
                title: "Chat",
                icon: "message.fill",
                isPressed: pressedButton == "chat"
            ) {
                pressedButton = "chat"
                // TODO: Navigate to chat
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
                showingSchedule = true
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
                // TODO: Navigate to AI assistant
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
                showingRoster = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    pressedButton = nil
                }
            }
        }
    }
}

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

// MARK: - Hero Cards

struct NextEventHeroCard: View {
    let event: Schedule
    let team: Team

    var timeUntilEvent: String {
        let interval = event.startTime.timeIntervalSince(Date())
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
                        .foregroundColor(.orange)

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
                    .foregroundColor(.orange.opacity(0.3))
            }

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(event.startTime.formatted(date: .abbreviated, time: .shortened))
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
                colors: [Color(white: 0.15), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
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
                    Text("YOUR TEAM")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)

                    Text(team.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(team.ageGroup)
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
                        .foregroundColor(.orange)
                }
            }

            HStack(spacing: 20) {
                Label("Team active", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)

                Label("Up to date", systemImage: "calendar.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(white: 0.15), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct NoTeamHeroCard: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: "sportscourt.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange.opacity(0.5))

            Text("No team joined")
                .font(.headline)
                .foregroundColor(.white)

            Text("Enter a team code to get started")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(white: 0.1))
        .cornerRadius(12)
    }
}

// MARK: - Communication Card

struct RecentAnnouncementsCard: View {
    let announcements: [Announcement]

    var recentAnnouncements: [Announcement] {
        announcements
            .sorted(by: { $0.createdAt > $1.createdAt })
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(recentAnnouncements) { announcement in
                HStack(spacing: 12) {
                    Circle()
                        .fill(priorityColor(announcement.priority))
                        .frame(width: 8, height: 8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(announcement.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text(announcement.message)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }

                    Spacer()

                    Text(timeAgo(announcement.createdAt))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                if announcement.id != recentAnnouncements.last?.id {
                    Divider()
                        .background(Color.gray.opacity(0.2))
                }
            }
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(12)
    }

    func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .urgent:
            return .red
        case .high:
            return .orange
        case .normal:
            return .blue
        case .low:
            return .gray
        }
    }

    func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval) / 3600

        if hours < 1 {
            let minutes = Int(interval) / 60
            return "\(minutes)m ago"
        } else if hours < 24 {
            return "\(hours)h ago"
        } else {
            let days = hours / 24
            return "\(days)d ago"
        }
    }
}

// MARK: - Week Calendar Card

struct WeekCalendarCard: View {
    let schedules: [Schedule]

    var thisWeekEvents: [Schedule] {
        let calendar = Calendar.current
        let now = Date()
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: now)!

        return schedules
            .filter { $0.startTime >= now && $0.startTime <= weekEnd }
            .sorted(by: { $0.startTime < $1.startTime })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if thisWeekEvents.isEmpty {
                Text("No events this week")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(thisWeekEvents.prefix(4)) { event in
                    HStack(spacing: 12) {
                        VStack(spacing: 2) {
                            Text(dayOfWeek(event.startTime))
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(dayNumber(event.startTime))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(width: 40)

                        Circle()
                            .fill(event.eventType == .game ? Color.orange : Color.green)
                            .frame(width: 4, height: 4)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.eventType.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)

                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption2)
                                Text(event.location)
                                    .font(.caption)
                            }
                            .foregroundColor(.gray)
                        }

                        Spacer()

                        Text(time(event.startTime))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    if event.id != thisWeekEvents.prefix(4).last?.id {
                        Divider()
                            .background(Color.gray.opacity(0.2))
                    }
                }
            }
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(12)
    }

    func dayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    func time(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Sticky Header

struct StickyParentHeader: View {
    let greeting: String
    let parentName: String
    let parentInitials: String
    let scrollOffset: CGFloat
    @Binding var height: CGFloat

    @State private var showingSettings = false
    @State private var showingNotifications = false

    private var isCompact: Bool {
        scrollOffset < -20
    }

    private var headerOpacity: Double {
        min(1.0, max(0.95, 1.0 - (scrollOffset / 200)))
    }

    private var scaleEffect: CGFloat {
        isCompact ? 0.95 : 1.0
    }

    private var verticalPadding: CGFloat {
        isCompact ? 8 : 16
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Profile Avatar
                Button(action: { showingSettings = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .orange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: isCompact ? 44 : 56, height: isCompact ? 44 : 56)

                        Text(parentInitials)
                            .font(.system(size: isCompact ? 16 : 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)

                        // Online indicator
                        if !isCompact {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .offset(x: 18, y: 18)
                        }
                    }
                }

                // Greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(greeting), \(parentName)")
                        .font(isCompact ? .headline : .title2)
                        .fontWeight(isCompact ? .semibold : .bold)
                        .foregroundColor(.white)
                }

                Spacer()

                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: { showingNotifications = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: isCompact ? 36 : 40, height: isCompact ? 36 : 40)

                            Image(systemName: "bell")
                                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                                .foregroundColor(.white)

                            // Notification badge
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .offset(x: 12, y: -12)
                        }
                    }

                    Button(action: { showingSettings = true }) {
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: isCompact ? 36 : 40, height: isCompact ? 36 : 40)
                            .overlay(
                                Image(systemName: "ellipsis")
                                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, verticalPadding)
            .background(
                ZStack {
                    Color.black
                        .opacity(headerOpacity)

                    if isCompact {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                    }
                }
                .ignoresSafeArea(edges: .top)
            )

            if isCompact {
                Divider()
                    .background(Color.gray.opacity(0.3))
            }
        }
        .scaleEffect(scaleEffect)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isCompact)
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
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.orange)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Spacer()
        }
    }
}

// MARK: - Scroll View with Offset

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

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Team.self, Schedule.self, Announcement.self])
}
