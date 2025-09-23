//
//  EditScheduleView.swift
//  ExpressCoach
//
//  Created on 9/22/25.
//

import SwiftUI
import SwiftData

struct EditScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let schedule: Schedule

    @State private var eventType: Schedule.EventType
    @State private var opponent: String
    @State private var location: String
    @State private var address: String
    @State private var date: Date
    @State private var arrivalTime: Date?
    @State private var isHome: Bool
    @State private var notes: String
    @State private var requireArrivalTime: Bool
    @State private var isCancelled: Bool

    @State private var showingDeleteAlert = false

    init(schedule: Schedule) {
        self.schedule = schedule
        _eventType = State(initialValue: schedule.eventType)
        _opponent = State(initialValue: schedule.opponent ?? "")
        _location = State(initialValue: schedule.location)
        _address = State(initialValue: schedule.address ?? "")
        _date = State(initialValue: schedule.date)
        _arrivalTime = State(initialValue: schedule.arrivalTime)
        _isHome = State(initialValue: schedule.isHome)
        _notes = State(initialValue: schedule.notes ?? "")
        _requireArrivalTime = State(initialValue: schedule.arrivalTime != nil)
        _isCancelled = State(initialValue: schedule.isCancelled)
    }

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

                Section("Status") {
                    Toggle("Event Cancelled", isOn: $isCancelled)
                        .tint(.red)
                }

                Section("Notes") {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Event")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Event")
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
            .alert("Delete Event?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteSchedule()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func saveSchedule() {
        schedule.eventType = eventType
        schedule.opponent = opponent.isEmpty ? nil : opponent
        schedule.location = location
        schedule.address = address.isEmpty ? nil : address
        schedule.date = date
        schedule.arrivalTime = requireArrivalTime ? arrivalTime : nil
        schedule.isHome = isHome
        schedule.notes = notes.isEmpty ? nil : notes
        schedule.isCancelled = isCancelled

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving schedule: \(error)")
        }
    }

    private func deleteSchedule() {
        modelContext.delete(schedule)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting schedule: \(error)")
        }
    }
}