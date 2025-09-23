//
//  RecentMessagesCard.swift
//  ExpressCoach
//
//  Recent message threads display for coach-to-team communication
//

import SwiftUI
import SwiftData

struct RecentMessagesCard: View {
    let team: Team
    @State private var showingMessageComposer = false
    @State private var selectedRecipient: MessageRecipient?

    // Mock data for now - will connect to real messaging system
    let recentThreads = [
        MessageThread(
            id: UUID(),
            recipientType: .parent,
            recipientName: "Sarah Chen",
            playerName: "Emma Chen",
            lastMessage: "Thanks coach! Emma will be at practice tomorrow.",
            timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
            unread: false,
            avatar: "person.circle.fill"
        ),
        MessageThread(
            id: UUID(),
            recipientType: .team,
            recipientName: "Team Announcement",
            playerName: nil,
            lastMessage: "Remember: Tournament this Saturday at 9 AM!",
            timestamp: Date().addingTimeInterval(-14400), // 4 hours ago
            unread: false,
            avatar: "person.3.fill"
        ),
        MessageThread(
            id: UUID(),
            recipientType: .player,
            recipientName: "Michael Johnson",
            playerName: nil,
            lastMessage: "Got it coach, I'll work on my free throws",
            timestamp: Date().addingTimeInterval(-86400), // Yesterday
            unread: true,
            avatar: "sportscourt.fill"
        ),
        MessageThread(
            id: UUID(),
            recipientType: .coach,
            recipientName: "Assistant Davis",
            playerName: nil,
            lastMessage: "I've updated the practice plan for tomorrow",
            timestamp: Date().addingTimeInterval(-172800), // 2 days ago
            unread: false,
            avatar: "person.badge.shield.checkmark.fill"
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "message.fill")
                        .foregroundColor(Color("BasketballOrange"))
                    Text("Recent Messages")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Spacer()

                Button(action: { showingMessageComposer = true }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(Color("BasketballOrange"))
                        .font(.title3)
                }
            }

            // Message threads
            if recentThreads.isEmpty {
                EmptyMessagesView()
            } else {
                VStack(spacing: 0) {
                    ForEach(recentThreads) { thread in
                        MessageThreadRow(thread: thread)
                            .onTapGesture {
                                // TODO: Open message thread
                            }

                        if thread.id != recentThreads.last?.id {
                            Divider()
                                .background(Color.gray.opacity(0.2))
                                .padding(.leading, 46)
                        }
                    }
                }
            }

            // View all messages link
            HStack {
                Spacer()
                NavigationLink(destination: MessagesListView()) {
                    Text("View All Messages")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color("BasketballOrange"))
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color("BackgroundDark"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("BasketballOrange").opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .sheet(isPresented: $showingMessageComposer) {
            NewMessageSheet()
        }
    }
}

struct MessageThread: Identifiable, Equatable {
    let id: UUID
    let recipientType: MessageRecipient
    let recipientName: String
    let playerName: String?
    let lastMessage: String
    let timestamp: Date
    let unread: Bool
    let avatar: String
}

enum MessageRecipient {
    case team
    case player
    case parent
    case coach

    var color: Color {
        switch self {
        case .team:
            return Color("BasketballOrange")
        case .player:
            return Color("CourtGreen")
        case .parent:
            return Color.blue
        case .coach:
            return Color.purple
        }
    }

    var label: String {
        switch self {
        case .team:
            return "TEAM"
        case .player:
            return "PLAYER"
        case .parent:
            return "PARENT"
        case .coach:
            return "COACH"
        }
    }
}

struct MessageThreadRow: View {
    let thread: MessageThread

    private var timeFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }

    var body: some View {
        HStack(spacing: 10) {
            // Avatar - smaller, more iOS-like size
            ZStack {
                Circle()
                    .fill(thread.recipientType.color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: thread.avatar)
                    .foregroundColor(thread.recipientType.color.opacity(0.9))
                    .font(.system(size: 16, weight: .medium))
            }

            // Message content - more compact 2-line layout
            VStack(alignment: .leading, spacing: 2) {
                // First line: Name and timestamp
                HStack(alignment: .top, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(thread.recipientName)
                            .font(.system(size: 15, weight: thread.unread ? .semibold : .regular))
                            .foregroundColor(.white)

                        if let playerName = thread.playerName {
                            Text("• \(playerName)")
                                .font(.system(size: 13))
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                    .lineLimit(1)

                    Spacer(minLength: 8)

                    HStack(spacing: 4) {
                        if thread.unread {
                            Circle()
                                .fill(Color("BasketballOrange"))
                                .frame(width: 6, height: 6)
                        }

                        Text(timeFormatter.localizedString(for: thread.timestamp, relativeTo: Date()))
                            .font(.system(size: 13))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }

                // Second line: Message preview
                Text(thread.lastMessage)
                    .font(.system(size: 14))
                    .foregroundColor(thread.unread ? .white.opacity(0.9) : .gray.opacity(0.8))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Chevron - more subtle
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.gray.opacity(0.3))
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

struct EmptyMessagesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "message")
                .font(.title2)
                .foregroundColor(.gray)

            Text("No recent messages")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("Start a conversation with your team")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

// Placeholder views - will be implemented later
struct MessagesListView: View {
    var body: some View {
        Text("All Messages")
            .navigationTitle("Messages")
    }
}

struct NewMessageSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recipientType = MessageRecipient.team
    @State private var messageText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipient") {
                    Picker("Send to", selection: $recipientType) {
                        Text("Entire Team").tag(MessageRecipient.team)
                        Text("Specific Player").tag(MessageRecipient.player)
                        Text("Parent").tag(MessageRecipient.parent)
                        Text("Coaching Staff").tag(MessageRecipient.coach)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Message") {
                    TextEditor(text: $messageText)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(messageText.isEmpty)
                }
            }
        }
    }
}