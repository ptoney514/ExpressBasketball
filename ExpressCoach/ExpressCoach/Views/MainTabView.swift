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
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
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

                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle.fill")
                    }
                    .tag(3)
            }
            .preferredColorScheme(.dark)
            .accentColor(Color("BasketballOrange"))
            .sheet(isPresented: $showingNotificationComposer) {
                NotificationComposerView()
            }

            // Demo Mode Indicator
            if demoDataManager.isDemoMode() {
                VStack {
                    HStack {
                        Spacer()
                        Label("Demo Mode", systemImage: "play.circle.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color("BasketballOrange").opacity(0.9))
                            )
                            .padding(.trailing, 16)
                            .padding(.top, 50)
                    }
                    Spacer()
                }
                .allowsHitTesting(false)
            }
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