//
//  ScheduleListView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI
import SwiftData

struct ScheduleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Schedule.startTime) private var schedules: [Schedule]
    @State private var selectedFilter: EventType?

    var filteredSchedules: [Schedule] {
        if let filter = selectedFilter {
            return schedules.filter { $0.eventType == filter }
        }
        return schedules
    }

    var upcomingSchedules: [Schedule] {
        filteredSchedules.filter { $0.startTime > Date() && !$0.isCancelled }
    }

    var pastSchedules: [Schedule] {
        filteredSchedules.filter { $0.startTime <= Date() || $0.isCancelled }
    }

    var body: some View {
        NavigationStack {
            List {
                if !upcomingSchedules.isEmpty {
                    Section("Upcoming") {
                        ForEach(upcomingSchedules) { schedule in
                            NavigationLink(destination: ScheduleDetailView(schedule: schedule)) {
                                ScheduleRowView(schedule: schedule)
                            }
                        }
                    }
                }

                if !pastSchedules.isEmpty {
                    Section("Past") {
                        ForEach(pastSchedules) { schedule in
                            NavigationLink(destination: ScheduleDetailView(schedule: schedule)) {
                                ScheduleRowView(schedule: schedule)
                                    .opacity(0.6)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Schedule")
            .cleanIOSHeader()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("All Events") {
                            selectedFilter = nil
                        }
                        Divider()
                        ForEach(EventType.allCases, id: \.self) { type in
                            Button(type.rawValue) {
                                selectedFilter = type
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .overlay {
                if schedules.isEmpty {
                    ContentUnavailableView(
                        "No Events",
                        systemImage: "calendar",
                        description: Text("Your team schedule will appear here")
                    )
                }
            }
        }
    }
}

struct ScheduleRowView: View {
    let schedule: Schedule

    var body: some View {
        HStack {
            Image(systemName: schedule.eventType.icon)
                .font(.title2)
                .foregroundStyle(Color(schedule.eventType.color))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(schedule.eventType.rawValue)
                        .font(.headline)
                    if schedule.isCancelled {
                        Text("CANCELLED")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }

                if let opponent = schedule.opponent {
                    Text("vs \(opponent)")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }

                Text(schedule.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(schedule.startTime.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(schedule.startTime.formatted(date: .omitted, time: .shortened))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 4)
    }
}