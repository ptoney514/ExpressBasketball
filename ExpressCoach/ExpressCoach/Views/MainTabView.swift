//
//  MainTabView.swift
//  ExpressCoach
//
//  Created on 9/18/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingNotificationComposer = false
    @State private var unreadMessages = 3

    var body: some View {
        TabView(selection: $selectedTab) {
            TeamDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "sportscourt.fill")
                }
                .tag(0)

            RosterView()
                .tabItem {
                    Label("Roster", systemImage: "person.3.fill")
                }
                .tag(1)

            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar.circle.fill")
                }
                .tag(2)

            AIAssistantView()
                .tabItem {
                    Label("Assistant", systemImage: "message.badge.filled.fill")
                }
                .badge(unreadMessages > 0 ? "\(unreadMessages)" : nil)
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .preferredColorScheme(.dark)
        .accentColor(Color("BasketballOrange"))
        .sheet(isPresented: $showingNotificationComposer) {
            NotificationComposerView()
        }
    }
}

// Placeholder view for the notification center
struct NotificationCenterView: View {
    @State private var showingNotificationComposer = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Communication Center")
                    .font(.title)
                    .padding()

                Button("Send Notification") {
                    showingNotificationComposer = true
                }
                .foregroundColor(.white)
                .padding()
                .background(Color("BasketballOrange"))
                .cornerRadius(10)
            }
            .navigationTitle("Notify")
            .sheet(isPresented: $showingNotificationComposer) {
                NotificationComposerView()
            }
        }
    }
}