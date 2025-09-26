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

    private let demoDataManager = DemoDataManager.shared

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TeamDashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                ChatView()
                    .tabItem {
                        Label("Chat", systemImage: "message.fill")
                    }
                    .tag(1)

                TeamRosterListView()
                    .tabItem {
                        Label("Teams", systemImage: "person.3.fill")
                    }
                    .tag(2)

                ScheduleView()
                    .tabItem {
                        Label("Schedule", systemImage: "calendar.circle.fill")
                    }
                    .tag(3)

                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle.fill")
                    }
                    .tag(4)

                SupabaseTestView()
                    .tabItem {
                        Label("Supabase", systemImage: "server.rack")
                    }
                    .tag(5)
            }
            .preferredColorScheme(.dark)
            .accentColor(Color("BasketballOrange"))
            .sheet(isPresented: $showingNotificationComposer) {
                NotificationComposerView()
            }

            // Demo Mode Indicator removed for TestFlight
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