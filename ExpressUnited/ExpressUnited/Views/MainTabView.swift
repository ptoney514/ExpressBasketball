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

            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(1)

            TeamsView()
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }
                .tag(2)

            ScheduleListView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
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