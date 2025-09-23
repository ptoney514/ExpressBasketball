import SwiftUI
import SwiftData
import AVFoundation

struct AICommunicationHub: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var teams: [Team]
    @Query(sort: \AIConversation.updatedAt, order: .reverse) private var conversations: [AIConversation]

    @State private var messageText = ""
    @State private var isRecording = false
    @State private var showingRecipientSheet = false
    @State private var showingAIPreview = false
    @State private var selectedRecipients = Set<RecipientType>()
    @State private var aiGeneratedMessage = ""
    @State private var isProcessingAI = false
    @State private var recentMessages: [CommunicationMessage] = []
    @State private var selectedQuickAction: QuickMessageType?
    @State private var showingVoiceAnimation = false

    @FocusState private var isMessageFieldFocused: Bool

    enum RecipientType: String, CaseIterable, Identifiable {
        case allParents = "All Parents"
        case allPlayers = "All Players"
        case allStaff = "All Staff"
        case specificTeam = "Specific Team"
        case individual = "Individual"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .allParents: return "figure.2"
            case .allPlayers: return "sportscourt"
            case .allStaff: return "person.3"
            case .specificTeam: return "person.2.circle"
            case .individual: return "person"
            }
        }

        var color: Color {
            switch self {
            case .allParents: return .blue
            case .allPlayers: return .green
            case .allStaff: return .purple
            case .specificTeam: return .orange
            case .individual: return .pink
            }
        }
    }

    enum QuickMessageType: String, CaseIterable, Identifiable {
        case practiceCancelled = "Practice Cancelled"
        case gameTimeChange = "Game Time Change"
        case weatherDelay = "Weather Delay"
        case tournamentInfo = "Tournament Info"
        case urgentUpdate = "Urgent Update"
        case teamMeeting = "Team Meeting"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .practiceCancelled: return "xmark.circle"
            case .gameTimeChange: return "clock.arrow.2.circlepath"
            case .weatherDelay: return "cloud.rain"
            case .tournamentInfo: return "trophy"
            case .urgentUpdate: return "exclamationmark.triangle"
            case .teamMeeting: return "person.3"
            }
        }

        var color: Color {
            switch self {
            case .practiceCancelled: return .red
            case .gameTimeChange: return .orange
            case .weatherDelay: return .blue
            case .tournamentInfo: return .purple
            case .urgentUpdate: return .red
            case .teamMeeting: return .green
            }
        }

        var template: String {
            switch self {
            case .practiceCancelled:
                return "Today's practice is cancelled due to [reason]. We'll resume our regular schedule [when]."
            case .gameTimeChange:
                return "Game time has been changed to [new time]. Please arrive [arrival time] for warm-ups."
            case .weatherDelay:
                return "Due to weather conditions, [event] is delayed. We'll update you as soon as we have more information."
            case .tournamentInfo:
                return "Tournament details: [location], [date/time]. Please bring [items needed]."
            case .urgentUpdate:
                return "URGENT: [message]. Please acknowledge receipt of this message."
            case .teamMeeting:
                return "Team meeting scheduled for [date/time] at [location]. Attendance is [required/optional]."
            }
        }
    }

    struct CommunicationMessage: Identifiable {
        let id = UUID()
        let content: String
        let recipients: String
        let timestamp: Date
        let status: MessageStatus
        let type: MessageType

        enum MessageStatus {
            case sent, delivered, read, failed

            var icon: String {
                switch self {
                case .sent: return "checkmark"
                case .delivered: return "checkmark.circle"
                case .read: return "checkmark.circle.fill"
                case .failed: return "exclamationmark.circle"
                }
            }

            var color: Color {
                switch self {
                case .sent, .delivered: return .gray
                case .read: return .blue
                case .failed: return .red
                }
            }
        }

        enum MessageType {
            case automated, manual, aiAssisted

            var badge: String {
                switch self {
                case .automated: return "AUTO"
                case .manual: return ""
                case .aiAssisted: return "AI"
                }
            }

            var color: Color {
                switch self {
                case .automated: return .orange
                case .manual: return .clear
                case .aiAssisted: return .blue
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gradient background
                LinearGradient(
                    colors: [
                        Color(UIColor.systemBackground),
                        Color(UIColor.secondarySystemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Recent Communications Section
                    ScrollView {
                        VStack(spacing: 20) {
                            // Quick Actions
                            QuickActionsSection(
                                selectedQuickAction: $selectedQuickAction,
                                onActionSelected: handleQuickAction
                            )

                            // Recent Messages
                            if !recentMessages.isEmpty {
                                RecentMessagesSection(messages: recentMessages)
                            }

                            // Stats Overview
                            CommunicationStatsOverview()
                        }
                        .padding(.bottom, 100) // Space for input area
                    }

                    Spacer()
                }

                // Floating Message Composer
                VStack {
                    Spacer()

                    CommunicationComposerView(
                        messageText: $messageText,
                        isRecording: $isRecording,
                        showingVoiceAnimation: $showingVoiceAnimation,
                        selectedRecipients: $selectedRecipients,
                        onSend: processAndSendMessage,
                        onVoiceToggle: toggleVoiceRecording,
                        onRecipientsToggle: { showingRecipientSheet = true },
                        isMessageFieldFocused: _isMessageFieldFocused
                    )
                }
            }
            .navigationTitle("Communication Hub")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { /* Show message history */ }) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { /* Show templates */ }) {
                            Label("Message Templates", systemImage: "doc.text")
                        }
                        Button(action: { /* Show settings */ }) {
                            Label("Communication Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingRecipientSheet) {
                RecipientSelectionSheet(selectedRecipients: $selectedRecipients)
            }
            .sheet(isPresented: $showingAIPreview) {
                AIMessagePreviewSheet(
                    originalMessage: messageText,
                    aiGeneratedMessage: $aiGeneratedMessage,
                    selectedRecipients: selectedRecipients,
                    onSend: sendFinalMessage,
                    onEdit: { showingAIPreview = false }
                )
            }
        }
        .onAppear {
            loadRecentMessages()
        }
    }

    // MARK: - Helper Functions

    private func handleQuickAction(_ action: QuickMessageType) {
        messageText = action.template
        selectedQuickAction = action
        isMessageFieldFocused = true

        // Auto-select appropriate recipients based on action
        switch action {
        case .practiceCancelled, .gameTimeChange, .weatherDelay:
            selectedRecipients = [.allParents, .allPlayers]
        case .tournamentInfo:
            selectedRecipients = [.allParents]
        case .urgentUpdate:
            selectedRecipients = [.allParents, .allPlayers, .allStaff]
        case .teamMeeting:
            selectedRecipients = [.allPlayers]
        }
    }

    private func processAndSendMessage() {
        guard !messageText.isEmpty else { return }

        isProcessingAI = true

        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Generate AI-enhanced message based on input
            aiGeneratedMessage = enhanceMessageWithAI(messageText)
            isProcessingAI = false
            showingAIPreview = true
        }
    }

    private func enhanceMessageWithAI(_ originalMessage: String) -> String {
        // Simulate AI enhancement - in production, this would call an AI service
        let greeting = getAppropriateGreeting()
        let closing = "Please don't hesitate to reach out if you have any questions.\n\nBest regards,\nCoach"

        // Clean up and formalize the message
        var enhanced = originalMessage
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")

        // Add professional structure
        enhanced = "\(greeting)\n\n\(enhanced)\n\n\(closing)"

        return enhanced
    }

    private func getAppropriateGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let dayGreeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
        return "\(dayGreeting) Express Basketball families,"
    }

    private func sendFinalMessage() {
        // Add to recent messages
        let newMessage = CommunicationMessage(
            content: aiGeneratedMessage,
            recipients: formatRecipients(),
            timestamp: Date(),
            status: .sent,
            type: .aiAssisted
        )

        recentMessages.insert(newMessage, at: 0)

        // Clear the composer
        messageText = ""
        aiGeneratedMessage = ""
        selectedRecipients.removeAll()
        showingAIPreview = false

        // Simulate delivery status update
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let index = recentMessages.firstIndex(where: { $0.id == newMessage.id }) {
                let updatedMessage = recentMessages[index]
                recentMessages[index] = CommunicationMessage(
                    content: updatedMessage.content,
                    recipients: updatedMessage.recipients,
                    timestamp: updatedMessage.timestamp,
                    status: .delivered,
                    type: updatedMessage.type
                )
            }
        }
    }

    private func formatRecipients() -> String {
        if selectedRecipients.isEmpty {
            return "No recipients selected"
        }
        return selectedRecipients.map { $0.rawValue }.joined(separator: ", ")
    }

    private func toggleVoiceRecording() {
        withAnimation(.spring()) {
            isRecording.toggle()
            showingVoiceAnimation = isRecording

            if isRecording {
                // Start recording
                HapticFeedback.impact(.medium)
            } else {
                // Stop recording and process
                HapticFeedback.impact(.light)
                // In production, this would process the audio to text
                messageText = "Practice is cancelled today due to field conditions"
            }
        }
    }

    private func loadRecentMessages() {
        // Load demo messages
        recentMessages = [
            CommunicationMessage(
                content: "Tomorrow's game has been moved to 3:00 PM. Please arrive by 2:30 PM for warm-ups.",
                recipients: "Express 14U Parents, Players",
                timestamp: Date().addingTimeInterval(-3600),
                status: .read,
                type: .aiAssisted
            ),
            CommunicationMessage(
                content: "Great job at today's practice! Keep up the hard work!",
                recipients: "Express 12U Players",
                timestamp: Date().addingTimeInterval(-7200),
                status: .delivered,
                type: .manual
            ),
            CommunicationMessage(
                content: "Tournament brackets have been posted. Check the team portal for details.",
                recipients: "All Parents",
                timestamp: Date().addingTimeInterval(-86400),
                status: .read,
                type: .automated
            )
        ]
    }
}

// MARK: - Subviews

struct CommunicationComposerView: View {
    @Binding var messageText: String
    @Binding var isRecording: Bool
    @Binding var showingVoiceAnimation: Bool
    @Binding var selectedRecipients: Set<AICommunicationHub.RecipientType>
    let onSend: () -> Void
    let onVoiceToggle: () -> Void
    let onRecipientsToggle: () -> Void
    @FocusState var isMessageFieldFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Recipients Bar
            if !selectedRecipients.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(selectedRecipients)) { recipient in
                            CommunicationRecipientChip(recipient: recipient)
                        }

                        Button(action: onRecipientsToggle) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 32)
            }

            // Message Input Area
            HStack(spacing: 12) {
                // Recipients button
                Button(action: onRecipientsToggle) {
                    Image(systemName: selectedRecipients.isEmpty ? "person.crop.circle.badge.plus" : "person.crop.circle.badge.checkmark")
                        .font(.title2)
                        .foregroundColor(selectedRecipients.isEmpty ? .gray : .blue)
                }

                // Text Field with Voice Overlay
                ZStack(alignment: .trailing) {
                    TextField("Type or dictate your message...", text: $messageText, axis: .vertical)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .padding(.trailing, 40)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(20)
                        .focused($isMessageFieldFocused)
                        .lineLimit(1...4)

                    // Voice Button
                    Button(action: onVoiceToggle) {
                        ZStack {
                            if showingVoiceAnimation {
                                Circle()
                                    .fill(Color.red.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .scaleEffect(showingVoiceAnimation ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.6).repeatForever(), value: showingVoiceAnimation)
                            }

                            Image(systemName: isRecording ? "mic.fill" : "mic")
                                .font(.system(size: 18))
                                .foregroundColor(isRecording ? .red : .gray)
                        }
                    }
                    .padding(.trailing, 8)
                }

                // AI Send Button
                Button(action: onSend) {
                    ZStack {
                        Circle()
                            .fill(messageText.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                            .frame(width: 44, height: 44)

                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .background(
            Color(.secondarySystemBackground)
                .opacity(0.98)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
}

struct CommunicationRecipientChip: View {
    let recipient: AICommunicationHub.RecipientType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: recipient.icon)
                .font(.caption)
            Text(recipient.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(recipient.color.opacity(0.15))
        .foregroundColor(recipient.color)
        .cornerRadius(12)
    }
}

struct QuickActionsSection: View {
    @Binding var selectedQuickAction: AICommunicationHub.QuickMessageType?
    let onActionSelected: (AICommunicationHub.QuickMessageType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AICommunicationHub.QuickMessageType.allCases) { action in
                        CommunicationQuickActionButton(
                            action: action,
                            isSelected: selectedQuickAction == action
                        ) {
                            onActionSelected(action)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CommunicationQuickActionButton: View {
    let action: AICommunicationHub.QuickMessageType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? action.color : action.color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: action.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : action.color)
                }

                Text(action.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 70)
            }
        }
    }
}

struct RecentMessagesSection: View {
    let messages: [AICommunicationHub.CommunicationMessage]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Communications")
                    .font(.headline)
                Spacer()
                Button("View All") {
                    // Show full history
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(messages.prefix(3)) { message in
                    MessageCard(message: message)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MessageCard: View {
    let message: AICommunicationHub.CommunicationMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if !message.type.badge.isEmpty {
                    Text(message.type.badge)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(message.type.color)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }

                Text(message.recipients)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: message.status.icon)
                        .font(.caption)
                        .foregroundColor(message.status.color)

                    Text(message.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(message.content)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct CommunicationStatsOverview: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Today's Stats")
                    .font(.headline)
                Spacer()
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                StatCard(
                    title: "Messages Sent",
                    value: "24",
                    trend: "+6",
                    icon: "paperplane.fill",
                    color: .blue
                )

                StatCard(
                    title: "Read Rate",
                    value: "96%",
                    trend: "+2%",
                    icon: "eye.fill",
                    color: .green
                )

                StatCard(
                    title: "AI Assists",
                    value: "18",
                    trend: "+3",
                    icon: "sparkles",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let trend: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)

                Text(trend)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Sheet Views

struct RecipientSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedRecipients: Set<AICommunicationHub.RecipientType>

    var body: some View {
        NavigationStack {
            List {
                Section("Select Recipients") {
                    ForEach(AICommunicationHub.RecipientType.allCases) { recipient in
                        HStack {
                            Image(systemName: recipient.icon)
                                .foregroundColor(recipient.color)
                                .frame(width: 30)

                            Text(recipient.rawValue)

                            Spacer()

                            if selectedRecipients.contains(recipient) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedRecipients.contains(recipient) {
                                selectedRecipients.remove(recipient)
                            } else {
                                selectedRecipients.insert(recipient)
                            }
                        }
                    }
                }

                Section {
                    Text("Selected: \(selectedRecipients.count) group(s)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .navigationTitle("Choose Recipients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct AIMessagePreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let originalMessage: String
    @Binding var aiGeneratedMessage: String
    let selectedRecipients: Set<AICommunicationHub.RecipientType>
    let onSend: () -> Void
    let onEdit: () -> Void

    @State private var editedMessage: String = ""
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // AI Badge
                    HStack {
                        Image(systemName: "sparkles")
                        Text("AI Enhanced Message")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .cornerRadius(20)

                    // Recipients
                    VStack(alignment: .leading, spacing: 8) {
                        Text("To:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        CommunicationFlowLayout(spacing: 8) {
                            ForEach(Array(selectedRecipients)) { recipient in
                                CommunicationRecipientChip(recipient: recipient)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(12)

                    // Message Preview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Message Preview")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Button(action: { isEditing.toggle() }) {
                                Label(isEditing ? "Done" : "Edit", systemImage: "pencil")
                                    .font(.caption)
                            }
                        }

                        if isEditing {
                            TextEditor(text: $editedMessage)
                                .frame(minHeight: 200)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                        } else {
                            Text(editedMessage.isEmpty ? aiGeneratedMessage : editedMessage)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(12)

                    // Original Message Reference
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your original message:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(originalMessage)
                            .font(.caption)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Review Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if !editedMessage.isEmpty {
                            aiGeneratedMessage = editedMessage
                        }
                        onSend()
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Text("Send")
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            editedMessage = aiGeneratedMessage
        }
    }
}

// MARK: - Helper Views

struct CommunicationFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))

                currentX += size.width + spacing
                maxX = max(maxX, currentX)
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxX - spacing, height: currentY + lineHeight)
        }
    }
}

// MARK: - Haptic Feedback Helper

struct HapticFeedback {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

// MARK: - Preview

struct AICommunicationHub_Previews: PreviewProvider {
    static var previews: some View {
        AICommunicationHub()
            .preferredColorScheme(.dark)
    }
}