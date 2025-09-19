import SwiftUI
import SwiftData

struct AIInsightsView: View {
    @Query private var conversations: [AIConversation]
    @Query private var quickResponses: [QuickResponse]
    @State private var selectedTimeRange = TimeRange.week

    enum TimeRange: String, CaseIterable {
        case today = "Today"
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }

    var filteredConversations: [AIConversation] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedTimeRange {
        case .today:
            return conversations.filter { calendar.isDateInToday($0.createdAt) }
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return conversations.filter { $0.createdAt >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return conversations.filter { $0.createdAt >= monthAgo }
        case .all:
            return conversations
        }
    }

    var responseRate: Double {
        guard !filteredConversations.isEmpty else { return 0 }
        let resolved = filteredConversations.filter { $0.status == .resolved }.count
        return Double(resolved) / Double(filteredConversations.count) * 100
    }

    var averageResponseTime: String {
        "< 5 min"
    }

    var aiHandledRate: Double {
        guard !filteredConversations.isEmpty else { return 0 }
        let aiHandled = filteredConversations.filter { $0.aiConfidence > 0.8 }.count
        return Double(aiHandled) / Double(filteredConversations.count) * 100
    }

    var mostCommonCategory: QuestionCategory {
        let categories = filteredConversations.map { $0.category }
        let counts = Dictionary(grouping: categories, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key ?? .general
    }

    var categoryBreakdown: [(QuestionCategory, Int)] {
        let categories = filteredConversations.map { $0.category }
        let counts = Dictionary(grouping: categories, by: { $0 }).mapValues { $0.count }
        return counts.sorted { $0.value > $1.value }.map { ($0.key, $0.value) }
    }

    var body: some View {
        ZStack {
            Color("BackgroundDark")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Time Range Selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Key Metrics
                    VStack(spacing: 16) {
                        Text("AI Performance Metrics")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            MetricCard(
                                title: "Response Rate",
                                value: String(format: "%.0f%%", responseRate),
                                icon: "checkmark.circle.fill",
                                color: .green,
                                trend: "+5%"
                            )

                            MetricCard(
                                title: "Avg Response Time",
                                value: averageResponseTime,
                                icon: "clock.fill",
                                color: .blue,
                                trend: "-2m"
                            )

                            MetricCard(
                                title: "AI Handled",
                                value: String(format: "%.0f%%", aiHandledRate),
                                icon: "sparkles",
                                color: .purple,
                                trend: "+12%"
                            )

                            MetricCard(
                                title: "Total Messages",
                                value: "\(filteredConversations.count)",
                                icon: "message.fill",
                                color: .orange,
                                trend: nil
                            )
                        }
                        .padding(.horizontal)
                    }

                    // Category Breakdown
                    VStack(spacing: 16) {
                        HStack {
                            Text("Question Categories")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(filteredConversations.count) total")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)

                        VStack(spacing: 12) {
                            ForEach(categoryBreakdown, id: \.0) { category, count in
                                CategoryRow(
                                    category: category,
                                    count: count,
                                    total: filteredConversations.count
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Template Usage
                    VStack(spacing: 16) {
                        HStack {
                            Text("Top Templates")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)

                        VStack(spacing: 12) {
                            ForEach(quickResponses.sorted(by: { $0.usageCount > $1.usageCount }).prefix(5)) { response in
                                TemplateUsageRow(response: response)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // AI Recommendations
                    VStack(spacing: 16) {
                        Text("AI Recommendations")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            RecommendationCard(
                                title: "Peak Activity Time",
                                description: "Most questions come between 6-8 PM. Consider scheduling availability.",
                                icon: "clock.arrow.circlepath"
                            )

                            RecommendationCard(
                                title: "Common Confusion",
                                description: "30% of questions about practice times. Add to team calendar.",
                                icon: "questionmark.bubble"
                            )

                            RecommendationCard(
                                title: "Template Opportunity",
                                description: "Create template for 'uniform color' questions (asked 8x this week).",
                                icon: "doc.text.fill"
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("AI Insights")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
                if let trend = trend {
                    Text(trend)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(trend.hasPrefix("+") ? .green : .red)
                }
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color("CoachBlack"))
        .cornerRadius(12)
    }
}

struct CategoryRow: View {
    let category: QuestionCategory
    let count: Int
    let total: Int

    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .foregroundColor(Color(category.color))
                    .frame(width: 20)

                Text(category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(category.color).opacity(0.7))
                            .frame(width: geometry.size.width * percentage, height: 20)
                    }
                }
                .frame(width: 80)

                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .frame(width: 30, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color("CoachBlack"))
        .cornerRadius(8)
    }
}

struct TemplateUsageRow: View {
    let response: QuickResponse

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(response.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Image(systemName: response.category.icon)
                        .font(.caption2)
                    Text(response.category.rawValue)
                        .font(.caption2)
                }
                .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(response.usageCount)")
                    .font(.headline)
                    .foregroundColor(Color("BasketballOrange"))

                Text("uses")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(Color("CoachBlack"))
        .cornerRadius(8)
    }
}

struct RecommendationCard: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("BasketballOrange"))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(Color("CoachBlack"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("BasketballOrange").opacity(0.3), lineWidth: 1)
        )
    }
}