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

    var upcomingSchedules: [Schedule] {
        filteredSchedules.filter { $0.date >= Date() && !$0.isCancelled }
    }

    var pastSchedules: [Schedule] {
        filteredSchedules.filter { $0.date < Date() || $0.isCancelled }
    }

    var body: some View {
        NavigationStack {
            Group {
                if currentTeam == nil {
                    NoTeamScheduleView()
                } else if schedules.isEmpty {
                    EmptyScheduleView(showingAddEvent: $showingAddEvent)
                } else {
                    ScheduleListView(
                        upcomingSchedules: upcomingSchedules,
                        pastSchedules: pastSchedules,
                        selectedSchedule: $selectedSchedule,
                        filterType: $filterType
                    )
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

struct EmptyScheduleView: View {
    @Binding var showingAddEvent: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.secondary)

            Text("No Events Scheduled")
                .font(.title)
                .bold()

            Text("Add games, practices, and events to your schedule")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: { showingAddEvent = true }) {
                Label("Add First Event", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct ScheduleListView: View {
    let upcomingSchedules: [Schedule]
    let pastSchedules: [Schedule]
    @Binding var selectedSchedule: Schedule?
    @Binding var filterType: Schedule.EventType?

    var body: some View {
        VStack {
            EventFilterView(filterType: $filterType)

            List {
                if !upcomingSchedules.isEmpty {
                    Section("Upcoming") {
                        ForEach(upcomingSchedules) { schedule in
                            ScheduleRowView(schedule: schedule)
                                .onTapGesture {
                                    selectedSchedule = schedule
                                }
                        }
                    }
                }

                if !pastSchedules.isEmpty {
                    Section("Past") {
                        ForEach(pastSchedules) { schedule in
                            ScheduleRowView(schedule: schedule)
                                .opacity(0.6)
                                .onTapGesture {
                                    selectedSchedule = schedule
                                }
                        }
                    }
                }
            }
        }
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
            .padding(.vertical, 8)
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

struct ScheduleRowView: View {
    let schedule: Schedule

    var eventIcon: String {
        switch schedule.eventType {
        case .game: return "sportscourt"
        case .practice: return "figure.basketball"
        case .tournament: return "trophy"
        case .scrimmage: return "figure.2.arms.open"
        case .teamEvent: return "person.3"
        }
    }

    var body: some View {
        HStack {
            Image(systemName: eventIcon)
                .font(.title2)
                .foregroundColor(schedule.isCancelled ? .red : .blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(schedule.eventType.rawValue)
                        .font(.headline)

                    if schedule.isCancelled {
                        Text("CANCELLED")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                    }
                }

                if let opponent = schedule.opponent {
                    Text("vs \(opponent)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text(schedule.location)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if schedule.isHome {
                        Text("• HOME")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(schedule.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(schedule.date, style: .time)
                    .font(.subheadline)
                    .bold()
            }
        }
        .padding(.vertical, 4)
    }
}