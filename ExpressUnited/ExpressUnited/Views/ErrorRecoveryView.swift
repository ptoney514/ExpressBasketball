//
//  ErrorRecoveryView.swift
//  ExpressUnited
//
//  Error recovery view for handling initialization failures
//

import SwiftUI

struct ErrorRecoveryView: View {
    let error: Error?
    let retryAction: (() -> Void)?
    
    @State private var showingDetails = false
    @Environment(\.colorScheme) var colorScheme
    
    init(error: Error? = nil, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Error Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .padding(.bottom, 8)
            
            // Title
            Text("Unable to Start App")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Description
            Text("We encountered an issue while starting the app. This might be a temporary problem.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Action Buttons
            VStack(spacing: 16) {
                if let retryAction = retryAction {
                    Button(action: retryAction) {
                        Label("Try Again", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                }
                
                Button(action: { showingDetails.toggle() }) {
                    Label(
                        showingDetails ? "Hide Details" : "Show Details",
                        systemImage: showingDetails ? "chevron.up" : "chevron.down"
                    )
                    .foregroundColor(.blue)
                }
                
                if showingDetails, let error = error {
                    ErrorDetailsView(error: error)
                        .padding(.horizontal, 32)
                        .transition(.opacity)
                }
            }
            
            Spacer()
            
            // Help Footer
            VStack(spacing: 8) {
                Text("If this problem persists:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Button("Clear Cache") {
                        clearAppCache()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Button("Reinstall App") {
                        openAppStore()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 32)
        }
        .animation(.easeInOut, value: showingDetails)
    }
    
    private func clearAppCache() {
        // Clear user defaults
        UserDefaults.standard.removeObject(forKey: "hasJoinedTeam")
        UserDefaults.standard.synchronize()
        
        // Try to restart the app
        if let retryAction = retryAction {
            retryAction()
        }
    }
    
    private func openAppStore() {
        // In production, this would open the App Store page
        if let url = URL(string: "https://apps.apple.com/app/express-united") {
            UIApplication.shared.open(url)
        }
    }
}

struct ErrorDetailsView: View {
    let error: Error
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Error Details")
                .font(.caption)
                .fontWeight(.semibold)
            
            ScrollView {
                Text(errorDescription)
                    .font(.system(.caption2, design: .monospaced))
                    .padding(8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .frame(maxWidth: CGFloat.infinity, alignment: .leading)
            }
            .frame(maxHeight: 120)
        }
    }
    
    private var errorDescription: String {
        let nsError = error as NSError
        var description = "Error: \(error.localizedDescription)\n"
        description += "Domain: \(nsError.domain)\n"
        description += "Code: \(nsError.code)\n"
        
        if !nsError.userInfo.isEmpty {
            description += "\nAdditional Info:\n"
            for (key, value) in nsError.userInfo {
                description += "  \(key): \(value)\n"
            }
        }
        
        return description
    }
}

// MARK: - In-Memory Container Fallback
struct InMemoryContainerView<Content: View>: View {
    @ViewBuilder let content: () -> Content
    let originalError: Error?
    
    @State private var showingWarning = true
    
    var body: some View {
        ZStack {
            content()
            
            if showingWarning {
                VStack {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        Text("Running in temporary mode - data won't be saved")
                            .font(.caption)
                        
                        Spacer()
                        
                        Button(action: { showingWarning = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding()
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: showingWarning)
    }
}