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

    var upcomingGames: [Schedule] {
        schedules
            .filter {
                $0.startTime > Date() &&
                ($0.eventType == .game || $0.eventType == .tournament)
            }
            .sorted(by: { $0.startTime < $1.startTime })
            .prefix(3)
            .map { $0 }
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

                    // Messages Section (Announcements) - Moved above games for priority
                    if !announcements.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Messages", icon: "message.fill")
                                .padding(.horizontal)

                            RecentAnnouncementsCard(announcements: announcements)
                                .padding(.horizontal)
                        }
                    }

                    // Upcoming Games/Tournaments Section
                    if !upcomingGames.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Upcoming Games", icon: "sportscourt.fill")
                                .padding(.horizontal)

                            UpcomingGamesCard(games: upcomingGames)
                                .padding(.horizontal)
                        }
                    }

                    // Coach's Corner - Inspirational Quote
                    CoachsCornerCard()
                        .padding(.horizontal)

                    // Training Video Section
                    TrainingVideoCard()
                        .padding(.horizontal)

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
            CleanIOSHeader(
                title: "Home",
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

// MARK: - Upcoming Games Card

struct UpcomingGamesCard: View {
    let games: [Schedule]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(games) { game in
                NavigationLink(destination: ScheduleDetailView(schedule: game)) {
                    HStack(spacing: 12) {
                        // Game Type Icon
                        ZStack {
                            Circle()
                                .fill(game.eventType == .tournament ? Color.purple.opacity(0.15) : Color.orange.opacity(0.15))
                                .frame(width: 44, height: 44)

                            Image(systemName: game.eventType == .tournament ? "trophy.fill" : "sportscourt.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(game.eventType == .tournament ? Color.purple : Color.orange)
                        }

                        // Game Details
                        VStack(alignment: .leading, spacing: 4) {
                            if let opponent = game.opponent {
                                Text("vs \(opponent)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            } else {
                                Text(game.eventType.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption2)
                                Text(game.location)
                                    .font(.caption)
                            }
                            .foregroundStyle(.gray)
                        }

                        Spacer()

                        // Date & Time
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(game.startTime.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(game.startTime.formatted(date: .omitted, time: .shortened))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())

                if game.id != games.last?.id {
                    Divider()
                        .background(Color.gray.opacity(0.2))
                }
            }
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(12)
    }
}

// MARK: - Messages Card (Announcements)

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

// MARK: - Coach's Corner Card

struct CoachsCornerCard: View {
    // Curated quotes from Coach K and other legendary coaches
    let quotes: [(quote: String, author: String)] = [
        ("The harder you work, the harder it is to surrender.", "Coach K"),
        ("Excellence is the gradual result of always striving to do better.", "Coach K"),
        ("A basketball team is like the five fingers on your hand. If you can get them all together, you have a fist.", "Coach K"),
        ("The only way to get people to like working hard is to motivate them. Today, people must understand why they're working hard.", "Coach K"),
        ("It's not about any one person. You've got to get over yourself and realize that it takes a group to get this thing done.", "Gregg Popovich"),
        ("Basketball is a beautiful game when the five players on the court play with one heartbeat.", "Dean Smith"),
        ("Good teams become great ones when the members trust each other enough to surrender the 'me' for the 'we'.", "Phil Jackson")
    ]

    @State private var currentQuoteIndex = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Coach's Corner", icon: "quote.opening")

            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "quote.closing")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.orange.opacity(0.3))

                Text(quotes[currentQuoteIndex].quote)
                    .font(.body)
                    .foregroundStyle(.white)
                    .lineSpacing(4)

                HStack {
                    Spacer()
                    Text("— \(quotes[currentQuoteIndex].author)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .onAppear {
            // Rotate through quotes daily
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
            currentQuoteIndex = dayOfYear % quotes.count
        }
    }
}

// MARK: - Training Video Card

struct TrainingVideoCard: View {
    // Sample training video - in production this would come from coach assignments
    let trainingVideo = (
        title: "Three Man Weave Drill",
        description: "Master this essential passing drill for next practice",
        duration: "4:32",
        thumbnail: "play.rectangle.fill",
        assignedBy: "Coach Mike"
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Training Video", icon: "play.rectangle.fill")

            Button(action: {
                // TODO: Open video player
            }) {
                VStack(spacing: 0) {
                    // Video thumbnail/preview
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 180)

                        VStack(spacing: 12) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.white)

                            Text("Tap to watch")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        // Duration badge
                        VStack {
                            HStack {
                                Spacer()
                                Text(trainingVideo.duration)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.black.opacity(0.7))
                                    .cornerRadius(4)
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }

                    // Video info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(trainingVideo.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Text(trainingVideo.description)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .lineLimit(2)

                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.caption)
                            Text("Assigned by \(trainingVideo.assignedBy)")
                                .font(.caption)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundStyle(.orange)
                    }
                    .padding()
                }
                .background(Color(white: 0.1))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
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

// MARK: - Clean iOS Header

struct CleanIOSHeader: View {
    let title: String
    let parentInitials: String
    let scrollOffset: CGFloat
    @Binding var height: CGFloat

    @State private var showingAccountMenu = false
    @State private var showingNotifications = false

    private var isCompact: Bool {
        scrollOffset < -20
    }

    private var headerOpacity: Double {
        min(1.0, max(0.95, 1.0 - (scrollOffset / 200)))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Profile Avatar Button (leads to account menu)
                Button(action: { showingAccountMenu = true }) {
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
                            Text(parentInitials)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.black)
                        )
                }

                // Title
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()

                // Notification Bell
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

                // More menu (ellipsis)
                Button(action: { showingAccountMenu = true }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
        .sheet(isPresented: $showingAccountMenu) {
            AccountMenuView()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationListView()
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
