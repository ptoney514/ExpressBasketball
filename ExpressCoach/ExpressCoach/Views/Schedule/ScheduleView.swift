//
//  ScheduleView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData

struct ScheduleView: View {
    @Query(sort: \Schedule.date, order: .forward) private var schedules: [Schedule]
    @Query private var teams: [Team]
    @State private var showingAddEvent = false
    @State private var selectedSchedule: Schedule?
    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()
    @State private var filterType: Schedule.EventType?

    var currentTeam: Team? {
        teams.first
    }

    var filteredSchedules: [Schedule] {
        if let filterType = filterType {
            return schedules.filter { $0.eventType == filterType }
        }
        return schedules
    }

    var selectedDateSchedules: [Schedule] {
        let calendar = Calendar.current
        return filteredSchedules.filter { schedule in
            calendar.isDate(schedule.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if currentTeam == nil {
                    NoTeamScheduleView()
                } else {
                    VStack(spacing: 0) {
                        CalendarView(
                            selectedDate: $selectedDate,
                            displayedMonth: $displayedMonth,
                            schedules: filteredSchedules
                        )

                        Divider()

                        EventFilterView(filterType: $filterType)
                            .padding(.vertical, 8)

                        Divider()

                        if selectedDateSchedules.isEmpty {
                            EmptyDayView(
                                date: selectedDate,
                                showingAddEvent: $showingAddEvent
                            )
                        } else {
                            SelectedDayScheduleList(
                                schedules: selectedDateSchedules,
                                selectedSchedule: $selectedSchedule
                            )
                        }
                    }
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEvent = true }) {
                        Image(systemName: "plus")
                    }
                    .disabled(currentTeam == nil)
                }
            }
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
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var displayedMonth: Date
    let schedules: [Schedule]

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    var monthYearString: String {
        dateFormatter.string(from: displayedMonth)
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

    func hasEvents(on date: Date) -> Bool {
        schedules.contains { schedule in
            calendar.isDate(schedule.date, inSameDayAs: date)
        }
    }

    func eventTypes(on date: Date) -> [Schedule.EventType] {
        let daySchedules = schedules.filter { schedule in
            calendar.isDate(schedule.date, inSameDayAs: date)
        }
        let types = Set(daySchedules.map { $0.eventType })
        return Array(types).sorted { $0.rawValue < $1.rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)

                Spacer()

                Text(monthYearString)
                    .font(.title2)
                    .bold()

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)

            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 12) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            eventTypes: eventTypes(on: date),
                            action: { selectedDate = date }
                        )
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
    }

    func previousMonth() {
        withAnimation {
            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        }
    }

    func nextMonth() {
        withAnimation {
            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let eventTypes: [Schedule.EventType]
    let action: () -> Void

    private let calendar = Calendar.current

    var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }

    var dotColors: [Color] {
        eventTypes.prefix(3).map { type in
            switch type {
            case .game: return .blue
            case .practice: return .green
            case .tournament: return .orange
            case .scrimmage: return .purple
            case .teamEvent: return .pink
            }
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isToday {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 36, height: 36)
                    }

                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 36, height: 36)
                    }

                    Text(dayNumber)
                        .font(.system(size: 16, weight: isToday ? .bold : .regular))
                        .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                }

                if !eventTypes.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(Array(dotColors.enumerated()), id: \.offset) { _, color in
                            Circle()
                                .fill(color)
                                .frame(width: 5, height: 5)
                        }
                    }
                } else {
                    Color.clear
                        .frame(height: 5)
                }
            }
            .frame(height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SelectedDayScheduleList: View {
    let schedules: [Schedule]
    @Binding var selectedSchedule: Schedule?

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(schedules) { schedule in
                    CompactScheduleCard(schedule: schedule)
                        .onTapGesture {
                            selectedSchedule = schedule
                        }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
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

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No events on")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(dateFormatter.string(from: date))
                .font(.title2)
                .bold()

            Button(action: { showingAddEvent = true }) {
                Label("Add Event", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
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

struct EventFilterView: View {
    @Binding var filterType: Schedule.EventType?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(title: "All", isSelected: filterType == nil) {
                    filterType = nil
                }

                ForEach(Schedule.EventType.allCases, id: \.self) { type in
                    FilterChip(title: type.rawValue, isSelected: filterType == type) {
                        filterType = filterType == type ? nil : type
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}