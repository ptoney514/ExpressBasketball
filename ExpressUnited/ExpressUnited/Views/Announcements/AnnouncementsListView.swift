//
//  AnnouncementsListView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI
import SwiftData

struct AnnouncementsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Announcement.createdAt, order: .reverse) private var announcements: [Announcement]
    @State private var selectedCategory: Category?

    var filteredAnnouncements: [Announcement] {
        let active = announcements.filter { announcement in
            if let expiresAt = announcement.expiresAt {
                return expiresAt > Date()
            }
            return true
        }

        if let category = selectedCategory {
            return active.filter { $0.category == category }
        }
        return active
    }

    var unreadCount: Int {
        filteredAnnouncements.filter { !$0.isRead }.count
    }

    var body: some View {
        NavigationStack {
            List {
                if unreadCount > 0 {
                    Section {
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            Text("\(unreadCount) unread announcement\(unreadCount == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                ForEach(filteredAnnouncements) { announcement in
                    NavigationLink(destination: AnnouncementDetailView(announcement: announcement)) {
                        AnnouncementRowView(announcement: announcement)
                    }
                }
            }
            .navigationTitle("News")
            .cleanIOSHeader()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("All Categories") {
                            selectedCategory = nil
                        }
                        Divider()
                        ForEach(Category.allCases, id: \.self) { category in
                            Button(action: { selectedCategory = category }) {
                                Label(category.rawValue, systemImage: category.icon)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .overlay {
                if announcements.isEmpty {
                    ContentUnavailableView(
                        "No Announcements",
                        systemImage: "megaphone",
                        description: Text("Team announcements will appear here")
                    )
                }
            }
        }
    }
}

struct AnnouncementRowView: View {
    let announcement: Announcement

    var body: some View {
        HStack {
            VStack(alignment: .center, spacing: 2) {
                Image(systemName: announcement.priority.icon)
                    .font(.title2)
                    .foregroundStyle(Color(announcement.priority.color))

                if !announcement.isRead {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(announcement.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(announcement.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack {
                    Label(announcement.category.rawValue, systemImage: announcement.category.icon)
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Spacer()

                    Text(announcement.createdAt.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}