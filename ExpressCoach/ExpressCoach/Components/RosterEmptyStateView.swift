//
//  RosterEmptyStateView.swift
//  ExpressCoach
//
//  Reusable empty state component for roster views
//

import SwiftUI

struct RosterEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)

                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    action()
                }) {
                    Label(actionTitle, systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(AppConstants.UI.cornerRadius)
                }
                .accessibilityHint("Double tap to \(actionTitle.lowercased())")
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

extension RosterEmptyStateView {
    static func noTeams(action: @escaping () -> Void) -> RosterEmptyStateView {
        RosterEmptyStateView(
            icon: "person.3",
            title: "No Teams Yet",
            message: "Create teams to manage rosters",
            actionTitle: "Create Team",
            action: action
        )
    }

    static func noPlayers(action: @escaping () -> Void) -> RosterEmptyStateView {
        RosterEmptyStateView(
            icon: "person.badge.plus",
            title: "No Players Yet",
            message: "Add players to build your roster",
            actionTitle: "Add First Player",
            action: action
        )
    }

    static func noSchedule(action: @escaping () -> Void) -> RosterEmptyStateView {
        RosterEmptyStateView(
            icon: "calendar.badge.plus",
            title: "No Events Scheduled",
            message: "Add practices, games, and events",
            actionTitle: "Add Event",
            action: action
        )
    }

    static func noAnnouncements(action: @escaping () -> Void) -> RosterEmptyStateView {
        RosterEmptyStateView(
            icon: "megaphone",
            title: "No Announcements",
            message: "Share important updates with your team",
            actionTitle: "Create Announcement",
            action: action
        )
    }

    static func searchNoResults(searchTerm: String) -> RosterEmptyStateView {
        RosterEmptyStateView(
            icon: "magnifyingglass",
            title: "No Results",
            message: "No matches found for '\(searchTerm)'"
        )
    }

    static func error(message: String, retry: @escaping () -> Void) -> RosterEmptyStateView {
        RosterEmptyStateView(
            icon: "exclamationmark.triangle",
            title: "Something Went Wrong",
            message: message,
            actionTitle: "Try Again",
            action: retry
        )
    }
}

struct RosterEmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            RosterEmptyStateView.noPlayers {
                print("Add player tapped")
            }

            RosterEmptyStateView.searchNoResults(searchTerm: "John")
        }
    }
}