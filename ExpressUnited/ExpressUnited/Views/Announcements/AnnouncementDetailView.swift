//
//  AnnouncementDetailView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct AnnouncementDetailView: View {
    @Bindable var announcement: Announcement

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: announcement.priority.icon)
                            .font(.title)
                            .foregroundStyle(Color(announcement.priority.color))

                        VStack(alignment: .leading) {
                            Text(announcement.priority.rawValue.uppercased())
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(announcement.priority.color))

                            Text(announcement.category.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(announcement.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))

                    Text(announcement.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    Text(announcement.message)
                        .font(.body)
                        .padding(.horizontal)

                    if let expiresAt = announcement.expiresAt {
                        HStack {
                            Image(systemName: "clock.badge.exclamationmark")
                                .foregroundStyle(.orange)
                            Text("Expires: \(expiresAt.formatted(date: .long, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }

                Spacer(minLength: 50)
            }
        }
        .navigationTitle("Announcement")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !announcement.isRead {
                announcement.isRead = true
            }
        }
    }
}