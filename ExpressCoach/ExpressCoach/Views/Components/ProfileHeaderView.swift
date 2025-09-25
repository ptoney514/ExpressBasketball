//
//  ProfileHeaderView.swift
//  ExpressCoach
//
//  Profile header with avatar and greeting for the dashboard
//

import SwiftUI

struct ProfileHeaderView: View {
    let team: Team
    let timeOfDayGreeting: String
    @State private var showingProfileView = false
    @State private var showingNotifications = false
    
    // Extract first name and initials from coach name
    private var coachFirstName: String {
        team.coachName.components(separatedBy: " ").first ?? "Coach"
    }
    
    private var coachInitials: String {
        let components = team.coachName.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.count > 1 ? String(components.last?.first?.uppercased() ?? "") : ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Avatar
            Button(action: { showingProfileView = true }) {
                ZStack {
                    // Avatar background with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("BasketballOrange"),
                                    Color("BasketballOrange").opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    // Initials or profile image
                    Text(coachInitials)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                    
                    // Online indicator
                    Circle()
                        .fill(Color("CourtGreen"))
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color("BackgroundDark"), lineWidth: 2)
                        )
                        .offset(x: 18, y: 18)
                }
            }
            .buttonStyle(ProfileScaleButtonStyle())
            
            // Greeting only - no title or team name
            VStack(alignment: .leading, spacing: 4) {
                Text("\(timeOfDayGreeting), \(coachFirstName)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Quick Actions
            HStack(spacing: 12) {
                // Notifications Button
                Button(action: { showingNotifications = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        
                        // Notification badge (if there are new notifications)
                        NotificationBadge()
                    }
                }
                .buttonStyle(ProfileScaleButtonStyle())
                
                // Settings/Menu Button
                Button(action: { showingProfileView = true }) {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
                .buttonStyle(ProfileScaleButtonStyle())
            }
        }
        .fullScreenCover(isPresented: $showingProfileView) {
            ProfileView()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsListView()
        }
    }
}

// Notification Badge Component
struct NotificationBadge: View {
    @State private var hasNotifications = true // This would come from a data source
    
    var body: some View {
        if hasNotifications {
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(Color("BackgroundDark"), lineWidth: 2)
                )
                .offset(x: 12, y: -12)
        }
    }
}

// Scale animation button style
struct ProfileScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Notifications List View (Modal)
struct NotificationsListView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        // Sample notifications
                        NotificationRow(
                            icon: "calendar",
                            title: "Practice Tomorrow",
                            message: "Don't forget about practice at 4:00 PM",
                            time: "2 hours ago",
                            isRead: false
                        )
                        
                        NotificationRow(
                            icon: "person.badge.plus",
                            title: "New Player Added",
                            message: "Michael Jordan joined the team",
                            time: "Yesterday",
                            isRead: true
                        )
                        
                        NotificationRow(
                            icon: "sportscourt.fill",
                            title: "Game Result",
                            message: "Great win! Final score 78-65",
                            time: "2 days ago",
                            isRead: true
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        // Clear notifications
                    }
                    .foregroundColor(Color("BasketballOrange"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("BasketballOrange"))
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

// Notification Row Component
struct NotificationRow: View {
    let icon: String
    let title: String
    let message: String
    let time: String
    let isRead: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(isRead ? Color.gray.opacity(0.15) : Color("BasketballOrange").opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isRead ? .gray : Color("BasketballOrange"))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(isRead ? .medium : .semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            // Unread indicator
            if !isRead {
                Circle()
                    .fill(Color("BasketballOrange"))
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(Color("CoachBlack"))
        .cornerRadius(12)
    }
}

#Preview {
    ZStack {
        Color("BackgroundDark")
            .ignoresSafeArea()
        
        ProfileHeaderView(
            team: Team(
                name: "Express United U16",
                ageGroup: "U16",
                coachName: "John Smith",
                coachRole: .headCoach
            ),
            timeOfDayGreeting: "Good evening"
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}