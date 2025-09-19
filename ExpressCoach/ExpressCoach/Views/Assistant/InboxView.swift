import SwiftUI
import SwiftData

struct InboxView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AIConversation.updatedAt, order: .reverse) private var allConversations: [AIConversation]
    @Binding var selectedConversation: AIConversation?
    @State private var filterStatus: ConversationFilter = .active

    enum ConversationFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case urgent = "Urgent"
        case unread = "Unread"

        var predicate: (AIConversation) -> Bool {
            switch self {
            case .all:
                return { _ in true }
            case .active:
                return { $0.status != .archived && $0.status != .resolved }
            case .urgent:
                return { $0.priority == .urgent }
            case .unread:
                return { !$0.isRead }
            }
        }
    }

    var filteredConversations: [AIConversation] {
        allConversations.filter(filterStatus.predicate)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ConversationFilter.allCases, id: \.self) { filter in
                        InboxFilterChip(
                            title: filter.rawValue,
                            isSelected: filterStatus == filter,
                            count: allConversations.filter(filter.predicate).count
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                filterStatus = filter
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            if filteredConversations.isEmpty {
                EmptyInboxView(filter: filterStatus)
            } else {
                List {
                    ForEach(filteredConversations) { conversation in
                        ConversationRow(conversation: conversation)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedConversation = conversation
                                if !conversation.isRead {
                                    conversation.isRead = true
                                    try? modelContext.save()
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(action: {
                                    archiveConversation(conversation)
                                }) {
                                    Label("Archive", systemImage: "archivebox")
                                }
                                .tint(.gray)

                                Button(action: {
                                    resolveConversation(conversation)
                                }) {
                                    Label("Resolve", systemImage: "checkmark")
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .leading) {
                                Button(action: {
                                    toggleUrgent(conversation)
                                }) {
                                    Label(
                                        conversation.priority == .urgent ? "Normal" : "Urgent",
                                        systemImage: conversation.priority == .urgent ? "flag.slash" : "flag"
                                    )
                                }
                                .tint(conversation.priority == .urgent ? .gray : .red)
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func archiveConversation(_ conversation: AIConversation) {
        withAnimation {
            conversation.status = .archived
            conversation.updatedAt = Date()
            try? modelContext.save()
        }
    }

    private func resolveConversation(_ conversation: AIConversation) {
        withAnimation {
            conversation.status = .resolved
            conversation.updatedAt = Date()
            try? modelContext.save()
        }
    }

    private func toggleUrgent(_ conversation: AIConversation) {
        withAnimation {
            conversation.priority = conversation.priority == .urgent ? .normal : .urgent
            conversation.updatedAt = Date()
            try? modelContext.save()
        }
    }
}

struct ConversationRow: View {
    let conversation: AIConversation

    var lastMessage: String {
        conversation.messages?.last?.content ?? conversation.subject
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: conversation.updatedAt, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(conversation.category.color).opacity(0.2))
                .overlay(
                    Image(systemName: conversation.category.icon)
                        .foregroundColor(Color(conversation.category.color))
                )
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.parentName)
                        .font(.headline)
                        .lineLimit(1)

                    if !conversation.isRead {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }

                    Spacer()

                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(conversation.subject)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack {
                    Text(lastMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    Spacer()

                    if conversation.aiConfidence > 0.8 {
                        HStack(spacing: 2) {
                            Image(systemName: "sparkles")
                            Text("AI Ready")
                        }
                        .font(.caption2)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(4)
                    }
                }

                if conversation.priority == .urgent {
                    Label("Urgent", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct InboxFilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color("BasketballOrange") : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct EmptyInboxView: View {
    let filter: InboxView.ConversationFilter

    var message: String {
        switch filter {
        case .all:
            return "No conversations yet"
        case .active:
            return "No active conversations"
        case .urgent:
            return "No urgent messages"
        case .unread:
            return "All caught up!"
        }
    }

    var icon: String {
        switch filter {
        case .all, .active:
            return "tray"
        case .urgent:
            return "flag.slash"
        case .unread:
            return "checkmark.circle"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)

            if filter == .unread {
                Text("Great job staying on top of parent questions!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }
}