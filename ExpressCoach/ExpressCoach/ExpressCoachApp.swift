//
//  ExpressCoachApp.swift
//  ExpressCoach
//
//  Created by Pernell Toney on 9/18/25.
//

import SwiftUI
import SwiftData

@main
struct ExpressCoachApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Team.self,
            Player.self,
            Schedule.self,
            Event.self,
            Announcement.self,
            AIConversation.self,
            AIMessage.self,
            QuickResponse.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct ContentView: View {
    @Query private var teams: [Team]

    var body: some View {
        Group {
            if teams.isEmpty {
                TeamSelectionView()
            } else {
                MainTabView()
            }
        }
    }
}
