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
            ScheduleListView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(0)

            RosterListView()
                .tabItem {
                    Label("Roster", systemImage: "person.3")
                }
                .tag(1)

            AnnouncementsListView()
                .tabItem {
                    Label("News", systemImage: "megaphone")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}