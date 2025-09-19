//
//  ScheduleDetailView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI
import MapKit

struct ScheduleDetailView: View {
    let schedule: Schedule
    @State private var showingDirections = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: schedule.eventType.icon)
                        .font(.title)
                        .foregroundStyle(Color(schedule.eventType.color))

                    VStack(alignment: .leading) {
                        Text(schedule.eventType.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)

                        if schedule.isCancelled {
                            Text("CANCELLED")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))

                VStack(alignment: .leading, spacing: 15) {
                    if let opponent = schedule.opponent {
                        DetailRow(
                            icon: "person.2",
                            title: "Opponent",
                            value: opponent
                        )
                    }

                    DetailRow(
                        icon: "calendar",
                        title: "Date",
                        value: schedule.startTime.formatted(date: .complete, time: .omitted)
                    )

                    DetailRow(
                        icon: "clock",
                        title: "Time",
                        value: "\(schedule.startTime.formatted(date: .omitted, time: .shortened)) - \(schedule.endTime?.formatted(date: .omitted, time: .shortened) ?? "TBD")"
                    )

                    DetailRow(
                        icon: "location",
                        title: "Location",
                        value: schedule.location
                    )

                    if schedule.eventType == .game {
                        DetailRow(
                            icon: "house",
                            title: "Game Type",
                            value: schedule.isHomeGame ? "Home" : "Away"
                        )
                    }

                    if let notes = schedule.notes, !notes.isEmpty {
                        DetailRow(
                            icon: "note.text",
                            title: "Notes",
                            value: notes
                        )
                    }

                    if schedule.isCancelled, let reason = schedule.cancellationReason {
                        DetailRow(
                            icon: "exclamationmark.triangle",
                            title: "Cancellation Reason",
                            value: reason
                        )
                        .foregroundStyle(.red)
                    }

                    if let teamScore = schedule.teamScore,
                       let opponentScore = schedule.opponentScore {
                        DetailRow(
                            icon: "sportscourt",
                            title: "Final Score",
                            value: "\(teamScore) - \(opponentScore)"
                        )
                        .fontWeight(.bold)
                    }
                }
                .padding()

                Button(action: { showingDirections = true }) {
                    Label("Get Directions", systemImage: "map")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDirections) {
            NavigationStack {
                VStack {
                    Text("Directions to \(schedule.location)")
                        .font(.title2)
                        .padding()

                    Spacer()

                    Text("Map integration would open here")
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .navigationTitle("Directions")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showingDirections = false
                        }
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }

            Spacer()
        }
    }
}