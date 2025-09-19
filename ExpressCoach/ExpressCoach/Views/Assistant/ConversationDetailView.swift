import SwiftUI
import SwiftData

struct ConversationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var conversation: AIConversation
    @State private var messageText = ""
    @State private var showingSuggestedResponses = false
    @State private var selectedSuggestion: String?
    @State private var isProcessingAI = false
    @Query private var quickResponses: [QuickResponse]

    var sortedMessages: [AIMessage] {
        (conversation.messages ?? []).sorted { $0.timestamp < $1.timestamp }
    }

    var applicableQuickResponses: [QuickResponse] {
        quickResponses.filter { $0.category == conversation.category }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ConversationHeader(conversation: conversation)

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(sortedMessages) { message in
                                ChatMessageView(
                                    message: message,
                                    showSuggestions: $showingSuggestedResponses,
                                    onSelectSuggestion: { suggestion in
                                        messageText = suggestion
                                    }
                                )
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: sortedMessages.count) { oldValue, newValue in
                        if let lastMessage = sortedMessages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                if showingSuggestedResponses {
                    SuggestedResponsesView(
                        conversation: conversation,
                        quickResponses: applicableQuickResponses,
                        onSelect: { response in
                            messageText = response
                            showingSuggestedResponses = false
                        }
                    )
                }

                MessageComposerView(
                    text: $messageText,
                    showingSuggestions: $showingSuggestedResponses,
                    isProcessingAI: isProcessingAI,
                    onSend: sendMessage,
                    onAISuggest: generateAIResponse
                )
            }
            .navigationTitle(conversation.parentName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    ConversationMenu(conversation: conversation)
                }
            }
        }
        .onAppear {
            if conversation.messages?.isEmpty ?? true {
                loadInitialMessage()
            }
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let message = AIMessage(
            content: messageText,
            isFromParent: false,
            senderName: "Coach"
        )

        conversation.messages?.append(message)
        conversation.updatedAt = Date()
        conversation.status = .inProgress

        messageText = ""
        try? modelContext.save()
    }

    private func generateAIResponse() {
        isProcessingAI = true
        showingSuggestedResponses = false

        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            await MainActor.run {
                messageText = generateContextualResponse()
                isProcessingAI = false
            }
        }
    }

    private func generateContextualResponse() -> String {
        switch conversation.category {
        case .practiceTime:
            return "Practice is scheduled for Tuesday and Thursday at 4:30 PM at the Community Center gym. Please arrive 10 minutes early for warm-ups."
        case .gameDetails:
            return "Our next game is Saturday at 2:00 PM at Lincoln High School. We'll be wearing white jerseys. Please arrive by 1:15 PM for team warm-up."
        case .uniform:
            return "Players should wear their white home jerseys for Saturday's game. Please bring both jerseys to all games in case of last-minute changes."
        case .travel:
            return "For the tournament, we'll meet at the school parking lot at 7:00 AM. The drive is about 1.5 hours. I'll share the exact address in the team chat."
        default:
            return "Thanks for your question! I'll get you that information shortly."
        }
    }

    private func loadInitialMessage() {
        let initialMessage = AIMessage(
            content: "Hi Coach, \(generateInitialQuestion())",
            isFromParent: true,
            senderName: conversation.parentName,
            sentiment: conversation.priority == .urgent ? .urgent : .neutral
        )

        conversation.messages = [initialMessage]
        try? modelContext.save()
    }

    private func generateInitialQuestion() -> String {
        switch conversation.category {
        case .practiceTime:
            return "What time is practice this week?"
        case .gameDetails:
            return "Can you send me the details for Saturday's game?"
        case .uniform:
            return "Which color jersey should my child wear for the game?"
        case .travel:
            return "What are the travel arrangements for the tournament?"
        case .registration:
            return "How do I register for the spring season?"
        case .emergency:
            return "This is urgent - my child was injured at practice. What should I do?"
        default:
            return "I have a quick question about the team."
        }
    }
}

struct ConversationHeader: View {
    let conversation: AIConversation

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label(conversation.category.rawValue, systemImage: conversation.category.icon)
                    .font(.caption)
                    .foregroundColor(Color(conversation.category.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(conversation.category.color).opacity(0.1))
                    .cornerRadius(12)

                if conversation.priority == .urgent {
                    Label("Urgent", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }

                Spacer()

                if conversation.aiConfidence > 0.8 {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("AI: \(Int(conversation.aiConfidence * 100))%")
                    }
                    .font(.caption)
                    .foregroundColor(.purple)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct ChatMessageView: View {
    let message: AIMessage
    @Binding var showSuggestions: Bool
    let onSelectSuggestion: (String) -> Void
    @State private var showingActions = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isFromParent { Spacer(minLength: 60) }

            VStack(alignment: message.isFromParent ? .leading : .trailing, spacing: 4) {
                HStack {
                    if !message.isFromParent { Spacer() }

                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if message.hasAISuggestion {
                        Label("AI", systemImage: "sparkles")
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }

                    if !message.isFromParent {
                        Text(timeString(from: message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    if message.isFromParent { Spacer() }
                }

                HStack {
                    if !message.isFromParent { Spacer() }

                    Text(message.content)
                        .padding(12)
                        .background(
                            message.isFromParent ?
                            Color.gray.opacity(0.2) :
                            Color("BasketballOrange")
                        )
                        .foregroundColor(message.isFromParent ? .primary : .white)
                        .cornerRadius(16)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = message.content
                            }) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }

                            if message.isFromParent {
                                Button(action: {
                                    showSuggestions = true
                                }) {
                                    Label("Suggest Response", systemImage: "sparkles")
                                }
                            }
                        }

                    if message.isFromParent { Spacer() }
                }

                if message.isFromParent && message.sentiment != .neutral {
                    HStack {
                        Image(systemName: message.sentiment.icon)
                        Text(message.sentiment.rawValue)
                    }
                    .font(.caption2)
                    .foregroundColor(Color(message.sentiment.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(message.sentiment.color).opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: 280)

            if message.isFromParent { Spacer(minLength: 60) }
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MessageComposerView: View {
    @Binding var text: String
    @Binding var showingSuggestions: Bool
    let isProcessingAI: Bool
    let onSend: () -> Void
    let onAISuggest: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                Button(action: {
                    showingSuggestions.toggle()
                }) {
                    Image(systemName: "text.bubble")
                        .foregroundColor(.gray)
                }

                Button(action: onAISuggest) {
                    if isProcessingAI {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                    }
                }
                .disabled(isProcessingAI)

                HStack {
                    TextField("Type a message...", text: $text, axis: .vertical)
                        .lineLimit(1...4)

                    Button(action: onSend) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(text.isEmpty ? .gray : Color("BasketballOrange"))
                    }
                    .disabled(text.isEmpty)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct ConversationMenu: View {
    let conversation: AIConversation

    var body: some View {
        Menu {
            Button(action: {}) {
                Label("Call Parent", systemImage: "phone")
            }

            Button(action: {}) {
                Label("View Player Profile", systemImage: "person.circle")
            }

            Divider()

            Menu {
                ForEach(AIConversation.Priority.allCases, id: \.self) { priority in
                    Button(action: {
                        conversation.priority = priority
                    }) {
                        if conversation.priority == priority {
                            Label(priority.rawValue, systemImage: "checkmark")
                        } else {
                            Text(priority.rawValue)
                        }
                    }
                }
            } label: {
                Label("Set Priority", systemImage: "flag")
            }

            Menu {
                ForEach(AIConversation.ConversationStatus.allCases, id: \.self) { status in
                    Button(action: {
                        conversation.status = status
                    }) {
                        if conversation.status == status {
                            Label(status.rawValue, systemImage: "checkmark")
                        } else {
                            Text(status.rawValue)
                        }
                    }
                }
            } label: {
                Label("Set Status", systemImage: "circle.dotted")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}