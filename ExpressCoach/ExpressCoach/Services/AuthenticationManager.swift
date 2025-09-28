import SwiftUI
import Supabase
import Combine

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentCoach: Coach?
    @Published var isLoading = true
    @Published var showAuthenticationView = false
    @Published var usesDemoMode = false
    
    private var authStateChangeListener: Task<Void, Never>?
    
    let supabase: SupabaseClient
    private let config = ConfigurationManager.shared
    
    private init() {
        self.supabase = SupabaseClient(
            supabaseURL: config.supabaseURL,
            supabaseKey: config.supabaseAnonKey
        )
        
        checkAuthState()
        listenToAuthStateChanges()
        
        config.log("🔐 AuthenticationManager initialized with \(config.environment) environment", level: .debug)
    }
    
    deinit {
        authStateChangeListener?.cancel()
    }
    
    private func checkAuthState() {
        Task {
            do {
                // Check if we have a session
                let session = try await supabase.auth.session
                await MainActor.run {
                    self.currentUser = session.user
                    self.isAuthenticated = true
                    self.isLoading = false
                }
            } catch {
                // No session - check if using demo mode
                await MainActor.run {
                    let isDemoMode = UserDefaults.standard.bool(forKey: "isDemoMode")
                    let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                    
                    self.usesDemoMode = isDemoMode
                    self.isAuthenticated = isDemoMode || hasCompletedOnboarding
                    self.isLoading = false
                    
                    // Show auth view if not authenticated and not in demo mode
                    if !self.isAuthenticated && !isDemoMode {
                        self.showAuthenticationView = true
                    }
                }
            }
        }
    }
    
    private func listenToAuthStateChanges() {
        authStateChangeListener = Task {
            for await (event, session) in supabase.auth.authStateChanges {
                await MainActor.run {
                    switch event {
                    case .signedIn:
                        self.currentUser = session?.user
                        self.isAuthenticated = true
                        self.showAuthenticationView = false
                        self.usesDemoMode = false
                        UserDefaults.standard.set(false, forKey: "isDemoMode")
                        
                    case .signedOut:
                        self.currentUser = nil
                        self.isAuthenticated = false
                        self.showAuthenticationView = true
                        
                    case .userUpdated:
                        self.currentUser = session?.user
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
                self.showAuthenticationView = true
                self.usesDemoMode = false
                
                // Clear stored preferences
                UserDefaults.standard.removeObject(forKey: "isDemoMode")
                UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            }
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    func enableDemoMode() {
        UserDefaults.standard.set(true, forKey: "isDemoMode")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        self.usesDemoMode = true
        self.isAuthenticated = true
        self.showAuthenticationView = false
    }
    
    func handleDeepLink(url: URL) async {
        do {
            // Handle magic link callback
            try await supabase.auth.session(from: url)
        } catch {
            print("Error handling deep link: \(error)")
        }
    }
}

// Supabase User extension for convenience
extension User {
    var displayName: String {
        userMetadata["full_name"]?.stringValue ?? email ?? "Coach"
    }
    
    var initials: String {
        let name = displayName
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return name.prefix(2).uppercased()
    }
}