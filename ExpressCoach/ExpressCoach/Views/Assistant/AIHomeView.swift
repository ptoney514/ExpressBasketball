import SwiftUI
import SwiftData

struct AIHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var teams: [Team]
    @Query(sort: \AIConversation.updatedAt, order: .reverse) private var conversations: [AIConversation]
    @Query private var quickResponses: [QuickResponse]
    @Binding var showingSendNotification: Bool
    @Binding var selectedConversation: AIConversation?

    var unreadCount: Int {
        conversations.filter { !$0.isRead }.count
    }

    var urgentCount: Int {
        conversations.filter { $0.priority == .urgent && $0.status != .resolved }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with AI Assistant branding
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                        .symbolEffect(.bounce, value: urgentCount)

                    Text("AI Coach Assistant")
                        .font(.title)
                        .bold()

                    Text("Your intelligent team communication hub")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Urgent Alert Banner
                if urgentCount > 0 {
                    UrgentAlertCard(count: urgentCount) {
                        // Navigate to urgent messages
                    }
                }

                // Quick Actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            QuickActionCard(
                                title: "Send Notification",
                                icon: "bell.badge",
                                color: .blue,
                                badge: nil
                            ) {
                                showingSendNotification = true
                            }

                            QuickActionCard(
                                title: "Check Messages",
                                icon: "tray",
                                color: .green,
                                badge: unreadCount > 0 ? "\(unreadCount)" : nil
                            ) {
                                // Navigate to inbox
                            }

                            QuickActionCard(
                                title: "Schedule Update",
                                icon: "calendar.badge.plus",
                                color: .orange,
                                badge: nil
                            ) {
                                // Navigate to schedule
                            }

                            QuickActionCard(
                                title: "Team Announcement",
                                icon: "megaphone",
                                color: .purple,
                                badge: nil
                            ) {
                                // Create announcement
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // AI Features
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("AI Features")
                            .font(.headline)
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        AIFeatureCard(
                            title: "Smart Response Suggestions",
                            description: "Get AI-powered response suggestions for parent questions",
                            icon: "text.bubble.fill",
                            color: .blue
                        )

                        AIFeatureCard(
                            title: "Auto-Draft Messages",
                            description: "Let AI help draft perfect team communications",
                            icon: "doc.text.fill",
                            color: .green
                        )

                        AIFeatureCard(
                            title: "Schedule Conflict Detection",
                            description: "AI monitors and alerts you to scheduling conflicts",
                            icon: "exclamationmark.triangle.fill",
                            color: .orange
                        )

                        AIFeatureCard(
                            title: "Communication Analytics",
                            description: "Track response times and parent engagement",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }

                // Recent Templates
                if !quickResponses.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Popular Templates")
                            .font(.headline)
                            Spacer()
                            Button("See All") {
                                // Navigate to templates
                            }
                            .font(.caption)
                        }
                        .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(quickResponses.prefix(5)) { response in
                                    TemplatePreviewCard(response: response)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // Stats Summary
                StatsOverview(conversations: conversations)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
    }
}

struct UrgentAlertCard: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(count) urgent message\(count == 1 ? "" : "s") need attention")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Tap to review")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.red, .red.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 40, height: 40)

                    if let badge = badge {
                        Text(badge)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(8)
                            .offset(x: 8, y: -8)
                    }
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(width: 100, height: 100)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct AIFeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct TemplatePreviewCard: View {
    let response: QuickResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: response.category.icon)
                    .font(.caption)
                    .foregroundColor(Color(response.category.color))

                Text(response.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }

            Text(response.template)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(3)

            if response.usageCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption2)
                    Text("Used \(response.usageCount)x")
                        .font(.caption2)
                }
                .foregroundColor(.green)
            }
        }
        .frame(width: 160, height: 100)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct StatsOverview: View {
    let conversations: [AIConversation]

    var responseRate: Double {
        guard !conversations.isEmpty else { return 0 }
        let resolved = conversations.filter { $0.status == .resolved }.count
        return Double(resolved) / Double(conversations.count) * 100
    }

    var todayMessages: Int {
        let calendar = Calendar.current
        let today = Date()
        return conversations.filter {
            calendar.isDate($0.createdAt, inSameDayAs: today)
        }.count
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Today's Activity")
                    .font(.headline)
                Spacer()
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                StatMiniCard(
                    title: "Messages",
                    value: "\(todayMessages)",
                    icon: "message.fill",
                    color: .blue
                )

                StatMiniCard(
                    title: "Response Rate",
                    value: String(format: "%.0f%%", responseRate),
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatMiniCard(
                    title: "Avg Time",
                    value: "< 5m",
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct StatMiniCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}