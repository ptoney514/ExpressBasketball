//
//  HomeView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct HomeView: View {
    @State private var userName = "Mike Johnson"
    @State private var userInitials = "MJ"

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Profile Header
                HStack(spacing: 16) {
                    // Avatar
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(userInitials)
                                .font(.headline)
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        // Show only the full name without greeting
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    // Notification Bell
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        // Quick Actions Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Actions")
                                .font(.headline)
                                .padding(.horizontal)

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                QuickActionCard(
                                    icon: "calendar",
                                    title: "Next Game",
                                    subtitle: "Today at 6:00 PM",
                                    color: .blue
                                )

                                QuickActionCard(
                                    icon: "megaphone",
                                    title: "Announcements",
                                    subtitle: "2 new updates",
                                    color: .orange
                                )

                                QuickActionCard(
                                    icon: "person.3",
                                    title: "Team Roster",
                                    subtitle: "15 players",
                                    color: .green
                                )

                                QuickActionCard(
                                    icon: "chart.bar",
                                    title: "Stats",
                                    subtitle: "View performance",
                                    color: .purple
                                )
                            }
                            .padding(.horizontal)
                        }

                        // Recent Activity Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Activity")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                ActivityRow(
                                    icon: "calendar.badge.plus",
                                    title: "New Practice Scheduled",
                                    time: "2 hours ago",
                                    color: .blue
                                )

                                ActivityRow(
                                    icon: "person.badge.plus",
                                    title: "Player Added to Roster",
                                    time: "5 hours ago",
                                    color: .green
                                )

                                ActivityRow(
                                    icon: "megaphone.fill",
                                    title: "Team Announcement",
                                    time: "Yesterday",
                                    color: .orange
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let time: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
}