//
//  MainTabView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @Query(filter: #Predicate<Announcement> { !$0.isRead }) private var unreadAnnouncements: [Announcement]

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ScheduleListView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(1)

            RosterListView()
                .tabItem {
                    Label("Roster", systemImage: "person.3.fill")
                }
                .tag(2)

            AnnouncementsListView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .badge(unreadAnnouncements.count)
                .tag(3)

            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DeepLinkToSchedule"))) { _ in
            selectedTab = 1 // Switch to Schedule tab
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DeepLinkToAnnouncement"))) { _ in
            selectedTab = 3 // Switch to Messages tab
        }
    }
}