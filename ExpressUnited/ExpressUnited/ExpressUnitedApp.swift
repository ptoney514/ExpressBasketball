//
//  ExpressUnitedApp.swift
//  ExpressUnited
//
//  Created by Pernell Toney on 9/18/25.
//

import SwiftUI
import SwiftData

@main
struct ExpressUnitedApp: App {
    @AppStorage("hasJoinedTeam") private var hasJoinedTeam = false
    @State private var containerError: Error?
    @State private var retryCount = 0

    var sharedModelContainer: ModelContainer? {
        let schema = Schema([
            Team.self,
            Player.self,
            Schedule.self,
            Event.self,
            Announcement.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Failed to create ModelContainer: \(error)")
            print("Error details: \(error.localizedDescription)")
            
            // Try to recover by creating a fresh container
            let storeURL = modelConfiguration.url
            print("Attempting to reset store at: \(storeURL)")
            
            do {
                try? FileManager.default.removeItem(at: storeURL)
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                // If all else fails, try in-memory container as fallback
                print("Failed to reset container, trying in-memory fallback: \(error)")
                containerError = error
                
                let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try? ModelContainer(for: schema, configurations: [memoryConfig])
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                // Normal app flow with container
                Group {
                    if containerError != nil {
                        // Wrap in InMemoryContainerView to show warning
                        InMemoryContainerView(
                            content: {
                                if hasJoinedTeam {
                                    MainTabView()
                                } else {
                                    TeamCodeEntryView(hasJoinedTeam: $hasJoinedTeam)
                                }
                            },
                            originalError: containerError
                        )
                    } else {
                        if hasJoinedTeam {
                            MainTabView()
                        } else {
                            TeamCodeEntryView(hasJoinedTeam: $hasJoinedTeam)
                        }
                    }
                }
                .modelContainer(container)
            } else {
                // Show error recovery view if container couldn't be created
                ErrorRecoveryView(
                    error: containerError,
                    retryAction: {
                        retryCount += 1
                        // Force a new attempt by clearing caches
                        UserDefaults.standard.synchronize()
                        // In a real app, you might want to restart the app
                        // For now, we'll just update the retry count which will trigger a rebuild
                    }
                )
            }
        }
    }
}
