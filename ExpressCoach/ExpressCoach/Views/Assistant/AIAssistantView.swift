import SwiftUI
import SwiftData

struct AIAssistantView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AIConversation.updatedAt, order: .reverse) private var conversations: [AIConversation]

    var body: some View {
        // Use the new Perplexity-style interface
        PerplexityStyleAssistantView()
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
                AssistantStatCard(
                    title: "Response Rate",
                    value: String(format: "%.0f%%", responseRate),
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                AssistantStatCard(
                    title: "Avg Response Time",
                    value: averageResponseTime,
                    icon: "clock.fill",
                    color: .blue
                )

                AssistantStatCard(
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

struct AssistantStatCard: View {
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