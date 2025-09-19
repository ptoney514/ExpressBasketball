//
//  AddScheduleView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI
import SwiftData

struct AddScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let team: Team

    @State private var eventType: Schedule.EventType = .game
    @State private var opponent = ""
    @State private var location = ""
    @State private var address = ""
    @State private var date = Date()
    @State private var arrivalTime: Date?
    @State private var isHome = true
    @State private var notes = ""
    @State private var requireArrivalTime = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Event Type") {
                    Picker("Type", selection: $eventType) {
                        ForEach(Schedule.EventType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Event Details") {
                    if eventType == .game || eventType == .scrimmage {
                        TextField("Opponent", text: $opponent)

                        Toggle("Home Game", isOn: $isHome)
                    }

                    TextField("Location", text: $location)
                    TextField("Address (optional)", text: $address)

                    DatePicker("Date & Time",
                              selection: $date,
                              displayedComponents: [.date, .hourAndMinute])

                    Toggle("Set Arrival Time", isOn: $requireArrivalTime)

                    if requireArrivalTime {
                        DatePicker("Arrival Time",
                                  selection: Binding(
                                    get: { arrivalTime ?? date.addingTimeInterval(-1800) },
                                    set: { arrivalTime = $0 }
                                  ),
                                  displayedComponents: .hourAndMinute)
                    }
                }

                Section("Notes") {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSchedule()
                    }
                    .bold()
                    .disabled(location.isEmpty)
                }
            }
        }
    }

    private func saveSchedule() {
        let schedule = Schedule(
            eventType: eventType,
            location: location,
            date: date,
            isHome: isHome
        )

        schedule.opponent = opponent.isEmpty ? nil : opponent
        schedule.address = address.isEmpty ? nil : address
        schedule.notes = notes.isEmpty ? nil : notes
        schedule.arrivalTime = requireArrivalTime ? arrivalTime : nil
        schedule.team = team

        modelContext.insert(schedule)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving schedule: \(error)")
        }
    }
}