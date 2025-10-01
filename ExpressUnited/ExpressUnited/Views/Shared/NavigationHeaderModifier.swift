//
//  NavigationHeaderModifier.swift
//  ExpressUnited
//
//  Reusable clean iOS-style header for all tab views
//

import SwiftUI

struct NavigationHeaderModifier: ViewModifier {
    let parentInitials: String

    @State private var showingAccountMenu = false
    @State private var showingNotifications = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingAccountMenu = true }) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .orange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(parentInitials)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black)
                            )
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { showingNotifications = true }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.primary)

                                // Red badge for unread notifications
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }

                        Button(action: { showingAccountMenu = true }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAccountMenu) {
                AccountMenuView()
            }
            .sheet(isPresented: $showingNotifications) {
                NotificationListView()
            }
    }
}

extension View {
    func cleanIOSHeader(parentInitials: String = "MJ") -> some View {
        modifier(NavigationHeaderModifier(parentInitials: parentInitials))
    }
}
