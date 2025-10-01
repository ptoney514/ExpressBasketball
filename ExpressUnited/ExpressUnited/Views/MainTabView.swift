//
//  MainTabView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

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
                    Label("News", systemImage: "megaphone.fill")
                }
                .tag(3)

            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
    }
}