//
//  ExpressCoachApp.swift
//  ExpressCoach
//
//  Created by Pernell Toney on 9/18/25.
//

import SwiftUI
import SwiftData
import Supabase

@main
struct ExpressCoachApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var syncService = SupabaseSyncService.shared
    @State private var containerError: Error?
    @State private var retryCount = 0
    
    var sharedModelContainer: ModelContainer? {
        let schema = Schema([
            Team.self,
            Player.self,
            Schedule.self,
            Event.self,
            Announcement.self,
            AIConversation.self,
            AIMessage.self,
            QuickResponse.self,
            Venue.self,
            Hotel.self,
            Airport.self,
            ParkingOption.self,
            Coach.self // Added Coach model
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Failed to create ModelContainer: \(error)")
            print("Error details: \(error.localizedDescription)")

            // Try to recover by creating a fresh container
            // Delete the existing store and create a new one
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
                                ContentView()
                                    .environmentObject(authManager)
                                    .environmentObject(syncService)
                            },
                            originalError: containerError
                        )
                    } else {
                        ContentView()
                            .environmentObject(authManager)
                            .environmentObject(syncService)
                    }
                }
                .modelContainer(container)
                .onOpenURL { url in
                    Task {
                        await authManager.handleDeepLink(url: url)
                    }
                }
                .onAppear {
                    // Configure sync service with model context
                    if let modelContext = container.mainContext as? ModelContext {
                        syncService.configure(with: modelContext)
                        
                        // Start syncing if authenticated
                        if authManager.isAuthenticated {
                            Task {
                                await syncService.performFullSync()
                                syncService.subscribeToRealtimeUpdates()
                            }
                        }
                    }
                    
                    // Load environment variables if available
                    EnvironmentFileLoader.loadIfExists()
                }
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

struct ContentView: View {
    @Query private var teams: [Team]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var isLoadingDemoData = false
    @State private var loadError: String?
    @State private var showAuthenticationView = false

    private let demoDataManager = DemoDataManager.shared

    var body: some View {
        Group {
            if authManager.isLoading {
                // Loading state
                ZStack {
                    Color("BackgroundDark")
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("BasketballOrange")))
                            .scaleEffect(1.5)
                        
                        Text("Loading...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            } else if let error = loadError {
                // Error state
                ZStack {
                    Color("BackgroundDark")
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)

                        Text("Unable to Load Data")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(error)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button(action: {
                            // Reset and try again
                            loadError = nil
                            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                            hasCompletedOnboarding = false
                        }) {
                            Text("Reset App")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color("BasketballOrange"))
                                .cornerRadius(10)
                        }
                    }
                }
            } else if !authManager.isAuthenticated && !authManager.usesDemoMode {
                // Show authentication options
                AuthenticationView()
                    .environmentObject(authManager)
            } else if !hasCompletedOnboarding && teams.isEmpty && authManager.usesDemoMode {
                // First launch with demo mode - show onboarding
                OnboardingView(onComplete: {
                    // When onboarding completes, set up demo data
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    hasCompletedOnboarding = true
                    setupDemoData()
                })
            } else if isLoadingDemoData {
                // Loading state while demo data is being created
                ZStack {
                    Color("BackgroundDark")
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("BasketballOrange")))
                            .scaleEffect(1.5)

                        Text("Setting up your demo team...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            } else {
                // Main app - go straight to dashboard
                MainTabView()
                    .onAppear {
                        // Ensure demo data exists
                        if teams.isEmpty {
                            setupDemoData()
                        }
                    }
            }
        }
        .onAppear {
            print("ContentView appeared")
            print("Has completed onboarding: \(hasCompletedOnboarding)")
            print("Number of teams: \(teams.count)")
        }
    }

    private func setupDemoData() {
        isLoadingDemoData = true
        loadError = nil

        Task {
            await MainActor.run {
                do {
                    // Enable demo mode
                    demoDataManager.setDemoMode(true)

                    // Create demo data if needed
                    if teams.isEmpty {
                        print("Creating demo data...")
                        try demoDataManager.seedDemoData(in: modelContext)
                        print("Demo data created successfully")
                    } else {
                        print("Teams already exist: \(teams.count) teams found")
                    }

                    isLoadingDemoData = false
                } catch {
                    print("Failed to create demo data: \(error)")
                    loadError = "Failed to load data: \(error.localizedDescription)"
                    isLoadingDemoData = false
                }
            }
        }
    }
}
