//
//  ScheduleView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData
import Combine

struct ScheduleView: View {
    @Query(sort: \Schedule.date, order: .forward) private var schedules: [Schedule]
    @Query private var teams: [Team]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddEvent = false
    @State private var selectedSchedule: Schedule?
    @State private var selectedDate = Date()
    @State private var viewMode: ViewMode = .week
    @State private var currentWeek = Date()
    @State private var scrollToHour: Int? = nil

    enum ViewMode: String, CaseIterable {
        case month = "MONTH"
        case week = "WEEK"
        case list = "LIST"
    }

    var currentTeam: Team? {
        teams.first
    }

    var selectedDateSchedules: [Schedule] {
        let calendar = Calendar.current
        return schedules.filter { schedule in
            calendar.isDate(schedule.date, inSameDayAs: selectedDate)
        }.sorted { $0.date < $1.date }
    }

    var weekSchedules: [Schedule] {
        let calendar = Calendar.current
        let weekDays = getWeekDates(for: currentWeek)
        return schedules.filter { schedule in
            weekDays.contains { date in
                calendar.isDate(schedule.date, inSameDayAs: date)
            }
        }.sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            Group {
                if currentTeam == nil {
                    NoTeamScheduleView()
                } else {
                    ZStack(alignment: .bottomTrailing) {
                        VStack(spacing: 0) {
                            // Header with segmented control
                            VStack(spacing: 0) {
                                ViewModeSelector(selectedMode: $viewMode)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                    .padding(.bottom, 16)

                                if viewMode == .week {
                                    WeekSelector(
                                        selectedDate: $selectedDate,
                                        currentWeek: $currentWeek,
                                        schedules: schedules,
                                        onDateSelected: { date in
                                            selectedDate = date
                                            // Find first event hour to scroll to
                                            let dayEvents = schedules.filter { schedule in
                                                Calendar.current.isDate(schedule.date, inSameDayAs: date)
                                            }
                                            if let firstEvent = dayEvents.min(by: { $0.date < $1.date }) {
                                                scrollToHour = Calendar.current.component(.hour, from: firstEvent.date)
                                            }
                                        }
                                    )
                                }
                            }
                            .background(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 2)

                            // Content based on view mode
                            Group {
                                switch viewMode {
                                case .month:
                                    MonthCalendarView(
                                        selectedDate: $selectedDate,
                                        schedules: schedules,
                                        onScheduleSelected: { schedule in
                                            selectedSchedule = schedule
                                        }
                                    )
                                case .week:
                                    DayEventsListView(
                                        selectedDate: selectedDate,
                                        schedules: selectedDateSchedules,
                                        onScheduleSelected: { schedule in
                                            selectedSchedule = schedule
                                        }
                                    )
                                case .list:
                                    ScheduleListView(
                                        schedules: schedules,
                                        onScheduleSelected: { schedule in
                                            selectedSchedule = schedule
                                        }
                                    )
                                }
                            }
                        }

                        // Floating Action Button
                        if currentTeam != nil {
                            Button(action: { showingAddEvent = true }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.3), radius: 4, y: 2)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddEvent) {
                if let team = currentTeam {
                    AddScheduleView(team: team)
                }
            }
            .sheet(item: $selectedSchedule) { schedule in
                ScheduleDetailView(schedule: schedule)
            }
        }
    }

    private func getWeekDates(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date

        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
}

// MARK: - View Mode Selector
struct ViewModeSelector: View {
    @Binding var selectedMode: ScheduleView.ViewMode
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ScheduleView.ViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedMode == mode ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if selectedMode == mode {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black)
                                        .matchedGeometryEffect(id: "selector", in: animation)
                                }
                            }
                        )
                }
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Week Selector
struct WeekSelector: View {
    @Binding var selectedDate: Date
    @Binding var currentWeek: Date
    let schedules: [Schedule]
    let onDateSelected: (Date) -> Void

    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    var weekDates: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Week navigation
            HStack {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(weekRangeText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Week days
            HStack(spacing: 0) {
                ForEach(weekDates, id: \.self) { date in
                    WeekDayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        events: eventsOn(date),
                        onTap: {
                            onDateSelected(date)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .onAppear {
            // Set current week based on selected date
            currentWeek = selectedDate
        }
    }

    private var weekRangeText: String {
        guard let first = weekDates.first,
              let last = weekDates.last else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        if calendar.component(.month, from: first) == calendar.component(.month, from: last) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "d"
            return "\(formatter.string(from: first)) - \(dayFormatter.string(from: last))"
        } else {
            return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
        }
    }

    private func eventsOn(_ date: Date) -> [Schedule] {
        schedules.filter { schedule in
            calendar.isDate(schedule.date, inSameDayAs: date)
        }
    }

    private func previousWeek() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek) ?? currentWeek
        }
    }

    private func nextWeek() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
        }
    }
}

// MARK: - Week Day Cell
struct WeekDayCell: View {
    let date: Date
    let isSelected: Bool
    let events: [Schedule]
    let onTap: () -> Void

    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    var isToday: Bool {
        calendar.isDateInToday(date)
    }

    var eventColors: [Color] {
        let types = Set(events.map { $0.eventType })
        return types.map { type in
            switch type {
            case .game: return .green
            case .practice: return .blue
            case .tournament, .scrimmage, .teamEvent: return .orange
            }
        }.sorted { $0.description < $1.description }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(dayFormatter.string(from: date).uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .gray)

                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                    .frame(width: 36, height: 36)
                    .background(
                        Group {
                            if isSelected {
                                Circle()
                                    .fill(Color.black)
                            } else if isToday {
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                            }
                        }
                    )

                // Event indicators
                HStack(spacing: 4) {
                    ForEach(0..<min(eventColors.count, 3), id: \.self) { index in
                        Circle()
                            .fill(eventColors[index])
                            .frame(width: 6, height: 6)
                    }
                    if eventColors.count > 3 {
                        Text("+\(eventColors.count - 3)")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 8)
                .opacity(eventColors.isEmpty ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Day Events List View
struct DayEventsListView: View {
    let selectedDate: Date
    let schedules: [Schedule]
    let onScheduleSelected: (Schedule) -> Void

    var sortedSchedules: [Schedule] {
        schedules.sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header showing selected date
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(selectedDate.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !schedules.isEmpty {
                    Text("\(schedules.count) event\(schedules.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))

            Divider()

            if schedules.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.minus")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)

                    Text("No events scheduled")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Tap the + button to add an event")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedSchedules) { schedule in
                            ScheduleEventRow(
                                schedule: schedule,
                                onTap: { onScheduleSelected(schedule) }
                            )

                            if schedule != sortedSchedules.last {
                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Schedule Event Row
struct ScheduleEventRow: View {
    let schedule: Schedule
    let onTap: () -> Void

    @State private var isPressed = false

    var eventColor: Color {
        switch schedule.eventType {
        case .game: return .green
        case .practice: return .blue
        case .tournament: return .orange
        case .scrimmage: return .purple
        case .teamEvent: return .pink
        }
    }

    var eventIcon: String {
        switch schedule.eventType {
        case .game: return "sportscourt"
        case .practice: return "figure.run"
        case .tournament: return "trophy"
        case .scrimmage: return "flag.checkered"
        case .teamEvent: return "person.3"
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Time
                VStack(spacing: 2) {
                    Text(schedule.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: true, vertical: false)

                    if let arrivalTime = schedule.arrivalTime {
                        Text("Arrive \(arrivalTime.formatted(date: .omitted, time: .shortened))")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                .frame(minWidth: 75, alignment: .leading)

                // Event type indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(eventColor)
                    .frame(width: 4)
                    .frame(maxHeight: .infinity)

                // Event details
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: eventIcon)
                            .font(.system(size: 14))
                            .foregroundColor(eventColor)

                        Text(schedule.eventType.rawValue.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(eventColor)

                        if schedule.isCancelled {
                            Text("CANCELLED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                        } else if Calendar.current.isDateInToday(schedule.date) &&
                                  schedule.date.timeIntervalSinceNow > -3600 &&
                                  schedule.date.timeIntervalSinceNow < 3600 {
                            Text("LIVE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                        }

                        Spacer()
                    }

                    Text(schedule.opponent ?? schedule.location)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .strikethrough(schedule.isCancelled)

                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.system(size: 11))
                        Text(schedule.location)
                            .font(.system(size: 13))
                            .lineLimit(1)
                    }
                    .foregroundColor(.secondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .background(Color(.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Timeline View
struct TimelineView: View {
    let selectedDate: Date
    let schedules: [Schedule]
    @Binding var scrollToHour: Int?
    let onScheduleSelected: (Schedule) -> Void

    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    private let hours = Array(0...23)
    private let hourHeight: CGFloat = 80

    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var currentHour: Int {
        Calendar.current.component(.hour, from: currentTime)
    }

    var currentMinute: Int {
        Calendar.current.component(.minute, from: currentTime)
    }

    var currentTimeOffset: CGFloat {
        CGFloat(currentHour) * hourHeight + (CGFloat(currentMinute) / 60.0) * hourHeight
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ZStack(alignment: .topLeading) {
                    // Hours grid
                    VStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            HStack(alignment: .top, spacing: 16) {
                                // Time label
                                Text(formatHour(hour))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .frame(width: 50, alignment: .trailing)
                                    .padding(.top, -8)

                                // Divider line
                                VStack(spacing: 0) {
                                    Divider()
                                    Spacer()
                                }
                                .frame(height: hourHeight)
                            }
                            .id(hour)
                        }
                    }
                    .padding(.horizontal)

                    // Events overlay
                    HStack(spacing: 0) {
                        Spacer()
                            .frame(width: 66) // Time label width + spacing

                        GeometryReader { geometry in
                            ForEach(schedules) { schedule in
                                EventCard(
                                    schedule: schedule,
                                    width: geometry.size.width - 16,
                                    hourHeight: hourHeight,
                                    onTap: {
                                        onScheduleSelected(schedule)
                                    }
                                )
                                .offset(y: eventOffset(for: schedule))
                            }

                            // Current time indicator
                            if isToday {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 12, height: 12)

                                    Rectangle()
                                        .fill(Color.red)
                                        .frame(height: 1)
                                }
                                .offset(y: currentTimeOffset)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground))
            .onAppear {
                if let hour = scrollToHour {
                    withAnimation {
                        proxy.scrollTo(max(0, hour - 1), anchor: .top)
                    }
                    scrollToHour = nil
                } else if isToday {
                    // Scroll to current hour if today
                    withAnimation {
                        proxy.scrollTo(max(0, currentHour - 1), anchor: .top)
                    }
                }
            }
            .onReceive(timer) { _ in
                currentTime = Date()
            }
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour) \(period)"
    }

    private func eventOffset(for schedule: Schedule) -> CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: schedule.date)
        let minute = calendar.component(.minute, from: schedule.date)
        return CGFloat(hour) * hourHeight + (CGFloat(minute) / 60.0) * hourHeight
    }
}

// MARK: - Event Card
struct EventCard: View {
    let schedule: Schedule
    let width: CGFloat
    let hourHeight: CGFloat
    let onTap: () -> Void

    private var duration: TimeInterval {
        // Default duration of 1 hour for events
        3600
    }

    private var cardHeight: CGFloat {
        max(60, (duration / 3600) * hourHeight)
    }

    private var eventColor: Color {
        switch schedule.eventType {
        case .game:
            return Color.green
        case .practice:
            return Color.blue
        case .tournament, .scrimmage:
            return Color.orange
        case .teamEvent:
            return Color.purple
        }
    }

    private var isLive: Bool {
        let now = Date()
        let endDate = schedule.date.addingTimeInterval(duration)
        return schedule.date <= now && now <= endDate
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Color indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(eventColor)
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(schedule.eventType.rawValue.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(eventColor)

                        if isLive {
                            Text("LIVE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                        }

                        Spacer()
                    }

                    Text(schedule.opponent ?? schedule.location)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .strikethrough(schedule.isCancelled)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(timeFormatter.string(from: schedule.date))
                            .font(.system(size: 12))

                        if !schedule.location.isEmpty {
                            Text("•")
                                .font(.system(size: 10))
                            Text(schedule.location)
                                .font(.system(size: 12))
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(.gray)

                    if schedule.isCancelled {
                        Text("CANCELLED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.red)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: width, height: cardHeight, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(schedule.isCancelled ? Color.red : eventColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
            .opacity(schedule.isCancelled ? 0.7 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Month Calendar View
struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    let schedules: [Schedule]
    let onScheduleSelected: (Schedule) -> Void

    @State private var displayedMonth = Date()

    var body: some View {
        VStack(spacing: 0) {
            // Original calendar implementation
            CalendarView(
                selectedDate: $selectedDate,
                displayedMonth: $displayedMonth,
                schedules: schedules
            )

            // Selected day events
            if !selectedDateSchedules.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(selectedDateSchedules) { schedule in
                            CompactScheduleCard(schedule: schedule)
                                .onTapGesture {
                                    onScheduleSelected(schedule)
                                }
                        }
                    }
                    .padding()
                }
            } else {
                Spacer()
                EmptyScheduleView(date: selectedDate)
                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var selectedDateSchedules: [Schedule] {
        let calendar = Calendar.current
        return schedules.filter { schedule in
            calendar.isDate(schedule.date, inSameDayAs: selectedDate)
        }.sorted { $0.date < $1.date }
    }
}

// MARK: - Schedule List View
struct ScheduleListView: View {
    let schedules: [Schedule]
    let onScheduleSelected: (Schedule) -> Void
    @Environment(\.modelContext) private var modelContext

    @State private var filterType: Schedule.EventType?

    private var groupedSchedules: [(String, [Schedule])] {
        let filtered = filterType == nil ? schedules : schedules.filter { $0.eventType == filterType }
        let grouped = Dictionary(grouping: filtered) { schedule in
            DateFormatter.monthYear.string(from: schedule.date)
        }
        return grouped.sorted { $0.key < $1.key }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All",
                        isSelected: filterType == nil,
                        color: .blue
                    ) {
                        filterType = nil
                    }

                    ForEach(Schedule.EventType.allCases, id: \.self) { type in
                        FilterChip(
                            title: type.rawValue,
                            isSelected: filterType == type,
                            color: colorForEventType(type)
                        ) {
                            filterType = filterType == type ? nil : type
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            .background(Color(.systemBackground))

            List {
                ForEach(groupedSchedules, id: \.0) { month, monthSchedules in
                    Section {
                        ForEach(monthSchedules) { schedule in
                            CompactScheduleCard(schedule: schedule)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .onTapGesture {
                                    onScheduleSelected(schedule)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deleteSchedule(schedule)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        onScheduleSelected(schedule)
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(Color("BasketballOrange"))
                                }
                        }
                    } header: {
                        Text(month)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
        }
    }

    private func colorForEventType(_ type: Schedule.EventType) -> Color {
        switch type {
        case .game: return .green
        case .practice: return .blue
        case .tournament: return .orange
        case .scrimmage: return .purple
        case .teamEvent: return .pink
        }
    }

    private func deleteSchedule(_ schedule: Schedule) {
        modelContext.delete(schedule)
        do {
            try modelContext.save()
        } catch {
            print("Error deleting schedule: \(error)")
        }
    }
}

// MARK: - Empty Schedule View
struct EmptyScheduleView: View {
    let date: Date

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text("No events scheduled")
                .font(.headline)
                .foregroundColor(.primary)

            Text(dateFormatter.string(from: date))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : Color(.systemGray6))
                )
        }
    }
}

// Keep the original CalendarView for month view
struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var displayedMonth: Date
    let schedules: [Schedule]

    private let calendar = Calendar.current
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()

    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    var monthString: String {
        monthFormatter.string(from: displayedMonth)
    }

    var yearString: String {
        yearFormatter.string(from: displayedMonth)
    }

    var daysInMonth: [Date?] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        let numberOfDays = monthRange.count

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    func eventTypes(on date: Date) -> [Schedule.EventType] {
        let daySchedules = schedules.filter { schedule in
            calendar.isDate(schedule.date, inSameDayAs: date)
        }
        let types = Set(daySchedules.map { $0.eventType })
        return Array(types).sorted { $0.rawValue < $1.rawValue }
    }

    func eventCount(on date: Date) -> Int {
        schedules.filter { schedule in
            calendar.isDate(schedule.date, inSameDayAs: date)
        }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Month/Year header with better typography
            HStack(alignment: .center, spacing: 16) {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(ScaleButtonStyle())

                Spacer()

                VStack(spacing: 2) {
                    Text(monthString)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(yearString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(1)
                }

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            // Weekday headers with better styling
            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .textCase(.uppercase)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            // Calendar grid with improved spacing
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            eventTypes: eventTypes(on: date),
                            eventCount: eventCount(on: date),
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedDate = date
                                }
                            }
                        )
                    } else {
                        Color.clear
                            .frame(height: 52)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }

    func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        }
    }

    func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let eventTypes: [Schedule.EventType]
    let eventCount: Int
    let action: () -> Void

    private let calendar = Calendar.current

    var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }

    var primaryEventColor: Color {
        guard let firstType = eventTypes.first else { return .clear }
        switch firstType {
        case .game: return .blue
        case .practice: return .green
        case .tournament: return .orange
        case .scrimmage: return .purple
        case .teamEvent: return .pink
        }
    }

    var isPastDate: Bool {
        calendar.compare(date, to: Date(), toGranularity: .day) == .orderedAscending
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Background shape
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )

                VStack(spacing: 6) {
                    // Day number
                    Text(dayNumber)
                        .font(.system(size: 17, weight: fontWeight, design: .rounded))
                        .foregroundColor(textColor)

                    // Event indicator
                    if !eventTypes.isEmpty {
                        HStack(spacing: 3) {
                            // Show primary event color as larger indicator
                            Circle()
                                .fill(primaryEventColor)
                                .frame(width: 8, height: 8)

                            // Show count if more than 1 event
                            if eventCount > 1 {
                                Text("+\(eventCount - 1)")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(primaryEventColor)
                            }
                        }
                    }
                }
            }
            .frame(height: 52)
            .opacity(isPastDate && !isToday ? 0.6 : 1.0)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var backgroundColor: Color {
        if isSelected {
            return .accentColor
        } else if isToday {
            return Color.accentColor.opacity(0.1)
        } else {
            return Color(.systemGray6)
        }
    }

    private var borderColor: Color {
        if isToday && !isSelected {
            return .accentColor
        } else {
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        isToday && !isSelected ? 2 : 0
    }

    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .accentColor
        } else if isPastDate {
            return .secondary
        } else {
            return .primary
        }
    }

    private var fontWeight: Font.Weight {
        if isSelected || isToday {
            return .semibold
        } else {
            return .regular
        }
    }
}

// Custom button style for scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SelectedDayScheduleList: View {
    let schedules: [Schedule]
    @Binding var selectedSchedule: Schedule?

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }

    private var selectedDate: Date {
        schedules.first?.date ?? Date()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Day header
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("\(schedules.count) \(schedules.count == 1 ? "event" : "events") scheduled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Event cards
                VStack(spacing: 10) {
                    ForEach(schedules) { schedule in
                        CompactScheduleCard(schedule: schedule)
                            .onTapGesture {
                                selectedSchedule = schedule
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
    }
}

// Removed duplicate ScheduleCard struct - using the one from Components/ScheduleCard.swift

struct EmptyDayView: View {
    let date: Date
    @Binding var showingAddEvent: Bool

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var isPastDate: Bool {
        Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedAscending
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Compact empty state
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 48))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.secondary)

                VStack(spacing: 4) {
                    Text(emptyStateTitle)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(dateFormatter.string(from: date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)

            // Add event button (only for today or future dates)
            if !isPastDate {
                Button(action: { showingAddEvent = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                        Text("Add Event")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.accentColor)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }

            Spacer()
        }
        .padding()
    }

    private var iconName: String {
        if isToday {
            return "calendar.badge.exclamationmark"
        } else if isPastDate {
            return "calendar"
        } else {
            return "calendar.badge.plus"
        }
    }

    private var emptyStateTitle: String {
        if isToday {
            return "No events scheduled today"
        } else if isPastDate {
            return "No events were scheduled"
        } else {
            return "No events scheduled"
        }
    }
}

struct NoTeamScheduleView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 80))
                .foregroundColor(.secondary)

            Text("No Team Created")
                .font(.title)
                .bold()

            Text("Create a team first to manage your schedule")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

