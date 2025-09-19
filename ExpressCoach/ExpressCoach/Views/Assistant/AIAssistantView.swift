import SwiftUI
import SwiftData

struct AIAssistantView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AIConversation.updatedAt, order: .reverse) private var conversations: [AIConversation]
    @State private var selectedMode = AssistantMode.home
    @State private var showingSendNotification = false
    @State private var showingCompose = false
    @State private var selectedConversation: AIConversation?

    enum AssistantMode: String, CaseIterable {
        case home = "AI Assistant"
        case inbox = "Inbox"
        case templates = "Templates"

        var icon: String {
            switch self {
            case .home:
                return "sparkles"
            case .inbox:
                return "tray"
            case .templates:
                return "text.bubble"
            }
        }
    }

    var unreadCount: Int {
        conversations.filter { !$0.isRead }.count
    }

    var urgentCount: Int {
        conversations.filter { $0.priority == .urgent && $0.status != .resolved }.count
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if urgentCount > 0 {
                    UrgentBanner(count: urgentCount)
                }

                Picker("Mode", selection: $selectedMode) {
                    ForEach(AssistantMode.allCases, id: \.self) { mode in
                        HStack {
                            Image(systemName: mode.icon)
                            Text(mode.rawValue)
                        }
                        .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Group {
                    switch selectedMode {
                    case .home:
                        AIHomeView(
                            showingSendNotification: $showingSendNotification,
                            selectedConversation: $selectedConversation
                        )
                    case .inbox:
                        InboxView(selectedConversation: $selectedConversation)
                    case .templates:
                        QuickResponsesView()
                    }
                }
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCompose = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: markAllAsRead) {
                            Label("Mark All Read", systemImage: "envelope.open")
                        }
                        Button(action: archiveResolved) {
                            Label("Archive Resolved", systemImage: "archivebox")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingCompose) {
                ComposeMessageView()
            }
            .sheet(isPresented: $showingSendNotification) {
                SendNotificationView()
            }
            .sheet(item: $selectedConversation) { conversation in
                ConversationDetailView(conversation: conversation)
            }
        }
        .onAppear {
            setupDemoDataIfNeeded()
        }
    }

    private func markAllAsRead() {
        for conversation in conversations where !conversation.isRead {
            conversation.isRead = true
            conversation.updatedAt = Date()
        }
        try? modelContext.save()
    }

    private func archiveResolved() {
        for conversation in conversations where conversation.status == .resolved {
            conversation.status = .archived
            conversation.updatedAt = Date()
        }
        try? modelContext.save()
    }

    private func setupDemoDataIfNeeded() {
        if conversations.isEmpty {
            DemoDataGenerator.createDemoConversations(in: modelContext)
        }
    }
}

struct UrgentBanner: View {
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
            Text("\(count) urgent message\(count == 1 ? "" : "s") need attention")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.red)
    }
}

struct InsightsView: View {
    @Query private var conversations: [AIConversation]

    var responseRate: Double {
        guard !conversations.isEmpty else { return 0 }
        let resolved = conversations.filter { $0.status == .resolved }.count
        return Double(resolved) / Double(conversations.count) * 100
    }

    var averageResponseTime: String {
        "< 5 min"
    }

    var mostCommonCategory: QuestionCategory {
        let categories = conversations.map { $0.category }
        let counts = Dictionary(grouping: categories, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key ?? .general
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                StatCard(
                    title: "Response Rate",
                    value: String(format: "%.0f%%", responseRate),
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatCard(
                    title: "Avg Response Time",
                    value: averageResponseTime,
                    icon: "clock.fill",
                    color: .blue
                )

                StatCard(
                    title: "Most Common Topic",
                    value: mostCommonCategory.rawValue,
                    icon: mostCommonCategory.icon,
                    color: Color(mostCommonCategory.color)
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("AI Performance")
                        .font(.headline)

                    HStack {
                        Text("Questions Auto-Answered")
                        Spacer()
                        Text("68%")
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Coach Approval Rate")
                        Spacer()
                        Text("92%")
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Parent Satisfaction")
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(0..<5) { i in
                                Image(systemName: i < 4 ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ComposeMessageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recipient = ""
    @State private var message = ""
    @State private var category = QuestionCategory.general

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipient") {
                    TextField("Parent name or phone", text: $recipient)
                }

                Section("Category") {
                    Picker("Topic", selection: $category) {
                        ForEach(QuestionCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }

                Section("Message") {
                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(recipient.isEmpty || message.isEmpty)
                }
            }
        }
    }
}