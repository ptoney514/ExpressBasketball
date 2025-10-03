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
    @State private var sendPushNotification = true
    @State private var isSending = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    @StateObject private var pushService = PushNotificationService.shared

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

                Section {
                    Toggle(isOn: $sendPushNotification) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Send Push Notification")
                                .font(.body)
                            Text("Notify all parents on ExpressUnited app")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Parents will receive a push notification about this event")
                }
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSending)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSchedule()
                    }
                    .bold()
                    .disabled(location.isEmpty || isSending)
                }
            }
            .alert("Notification Sent", isPresented: $showAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
            .overlay {
                if isSending {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Sending notification...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(32)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
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

            // Send push notification if enabled
            if sendPushNotification {
                Task {
                    await sendPushNotificationToParents()
                }
            } else {
                dismiss()
            }
        } catch {
            print("Error saving schedule: \(error)")
        }
    }

    private func sendPushNotificationToParents() async {
        isSending = true

        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d 'at' h:mm a"
            let timeString = formatter.string(from: date)

            let notificationTitle = eventType == .game || eventType == .scrimmage
                ? "New \(eventType.rawValue): \(opponent.isEmpty ? "TBD" : "vs \(opponent)")"
                : "New \(eventType.rawValue)"

            let notificationBody = "\(timeString)\n📍 \(location)"

            let count = try await pushService.sendScheduleNotification(
                teamId: team.id,
                title: notificationTitle,
                details: notificationBody
            )

            alertMessage = "Notification sent to \(count) parent\(count == 1 ? "" : "s")"
            showAlert = true
        } catch {
            alertMessage = "Failed to send notification: \(error.localizedDescription)"
            showAlert = true
        }

        isSending = false
    }
}