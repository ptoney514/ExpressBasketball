//
//  ScheduleDetailView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI

struct ScheduleDetailView: View {
    let schedule: Schedule
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Schedule details coming soon")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}