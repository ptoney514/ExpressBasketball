//
//  MainTabView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TeamDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)

            RosterView()
                .tabItem {
                    Label("Roster", systemImage: "person.3.fill")
                }
                .tag(1)

            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(2)

            AnnouncementsView()
                .tabItem {
                    Label("Announcements", systemImage: "megaphone.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}