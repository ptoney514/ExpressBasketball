import SwiftUI
import SwiftData
import AVFoundation

struct PerplexityStyleAssistantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var teams: [Team]
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    @State private var showingRecipientSelection = false
    @State private var selectedRecipients = Set<RecipientType>()
    @State private var showingMessagePreview = false
    @State private var generatedMessage = ""
    @State private var selectedQuickAction: QuickAction?
    @State private var scrollToBottom = false
    @FocusState private var isInputFocused: Bool

    // MARK: - Data Models

    struct ChatMessage: Identifiable {
        let id = UUID()
        let content: String
        let isUser: Bool
        let timestamp: Date = Date()
        let quickAction: QuickAction?

        init(content: String, isUser: Bool, quickAction: QuickAction? = nil) {
            self.content = content
            self.isUser = isUser
            self.quickAction = quickAction
        }
    }

    enum QuickAction: String, CaseIterable, Identifiable {
        case practiceCancelled = "Practice Cancelled"
        case gameTimeChange = "Game Time Change"
        case practiceTips = "Practice Tips"
        case gamePlan = "Game Plan"
        case drillSuggestion = "Drill Ideas"
        case playerMotivation = "Player Motivation"
        case tournamentInfo = "Tournament Info"
        case urgentUpdate = "Urgent Update"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .practiceCancelled: return "xmark.circle.fill"
            case .gameTimeChange: return "clock.arrow.2.circlepath"
            case .practiceTips: return "lightbulb.fill"
            case .gamePlan: return "sportscourt.fill"
            case .drillSuggestion: return "figure.run"
            case .playerMotivation: return "star.fill"
            case .tournamentInfo: return "trophy.fill"
            case .urgentUpdate: return "exclamationmark.triangle.fill"
            }
        }

        var color: Color {
            switch self {
            case .practiceCancelled: return .red
            case .gameTimeChange: return .orange
            case .practiceTips: return .green
            case .gamePlan: return .blue
            case .drillSuggestion: return .purple
            case .playerMotivation: return .yellow
            case .tournamentInfo: return .indigo
            case .urgentUpdate: return .red
            }
        }

        var template: String {
            switch self {
            case .practiceCancelled:
                return "Today's practice is cancelled. When would you like to reschedule?"
            case .gameTimeChange:
                return "The game time has changed. What's the new time and location?"
            case .practiceTips:
                return "Generate practice plan focusing on fundamentals, defense, and shooting drills"
            case .gamePlan:
                return "Create game strategy for our next opponent including offensive plays and defensive schemes"
            case .drillSuggestion:
                return "Suggest 5 dribbling drills for improving ball handling and 3 defensive positioning exercises"
            case .playerMotivation:
                return "Write motivational message for players about teamwork, effort, and improvement"
            case .tournamentInfo:
                return "I need to share tournament information. What are the details?"
            case .urgentUpdate:
                return "I have an urgent update for the team. What's the situation?"
            }
        }

        var suggestedRecipients: Set<RecipientType> {
            switch self {
            case .practiceCancelled, .gameTimeChange:
                return [.allParents, .allPlayers]
            case .practiceTips, .gamePlan:
                return [.coaches]
            case .drillSuggestion, .playerMotivation:
                return [.allPlayers]
            case .tournamentInfo:
                return [.allParents]
            case .urgentUpdate:
                return [.allParents, .allPlayers, .coaches]
            }
        }
    }

    enum RecipientType: String, CaseIterable, Identifiable {
        case allParents = "All Parents"
        case allPlayers = "All Players"
        case coaches = "Coaches"
        case specific = "Specific"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .allParents: return "figure.2"
            case .allPlayers: return "sportscourt.fill"
            case .coaches: return "person.3.fill"
            case .specific: return "person.circle"
            }
        }

        var color: Color {
            switch self {
            case .allParents: return .blue
            case .allPlayers: return .green
            case .coaches: return .purple
            case .specific: return .orange
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Light background
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Chat Messages Area
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                // Welcome message when empty
                                if messages.isEmpty {
                                    EmptyStateView()
                                        .padding(.top, 40)
                                } else {
                                    // Chat messages
                                    LazyVStack(spacing: 16) {
                                        ForEach(messages) { message in
                                            MessageBubble(message: message)
                                                .id(message.id)
                                        }

                                        if isTyping {
                                            PerplexityTypingIndicator()
                                                .id("typing")
                                        }
                                    }
                                    .padding()
                                }

                                // Quick Actions (always visible at top when scrolled up)
                                if messages.isEmpty {
                                    QuickActionsGrid(
                                        selectedAction: $selectedQuickAction,
                                        onActionTapped: handleQuickAction
                                    )
                                    .padding()
                                    .padding(.bottom, 100)
                                }
                            }
                        }
                        .onChange(of: scrollToBottom) { _, newValue in
                            if newValue {
                                withAnimation {
                                    if let lastMessageId = messages.last?.id {
                                        proxy.scrollTo(lastMessageId, anchor: .bottom)
                                    } else if isTyping {
                                        proxy.scrollTo("typing", anchor: .bottom)
                                    }
                                }
                                scrollToBottom = false
                            }
                        }
                    }

                    // Input Area
                    InputAreaView(
                        messageText: $messageText,
                        selectedRecipients: $selectedRecipients,
                        isInputFocused: _isInputFocused,
                        onSend: sendMessage,
                        onRecipientsToggle: {
                            showingRecipientSelection = true
                        }
                    )
                }
            }
            .navigationTitle("AI Assistant Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: clearChat) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingRecipientSelection) {
                RecipientSelectionView(
                    selectedRecipients: $selectedRecipients
                )
            }
            .sheet(isPresented: $showingMessagePreview) {
                MessagePreviewView(
                    message: generatedMessage,
                    recipients: selectedRecipients,
                    onSend: finalizeAndSend,
                    onEdit: {
                        showingMessagePreview = false
                    }
                )
            }
        }
        .onAppear {
            setupInitialMessages()
        }
    }

    // MARK: - Actions

    private func setupInitialMessages() {
        if messages.isEmpty {
            let welcomeMessage = ChatMessage(
                content: "Hi Coach! I'm your AI assistant. I can help you communicate with your team, manage schedules, and handle urgent updates. How can I help you today?",
                isUser: false
            )
            messages.append(welcomeMessage)
        }
    }

    private func handleQuickAction(_ action: QuickAction) {
        // Add user message showing the quick action
        let userMessage = ChatMessage(
            content: action.rawValue,
            isUser: true,
            quickAction: action
        )
        messages.append(userMessage)

        // Set suggested recipients
        selectedRecipients = action.suggestedRecipients
        selectedQuickAction = action

        // Add AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isTyping = true
            scrollToBottom = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isTyping = false

                let aiResponse = ChatMessage(
                    content: action.template,
                    isUser: false
                )
                messages.append(aiResponse)

                // Pre-fill the message field
                messageText = ""
                isInputFocused = true
                scrollToBottom = true
            }
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Add user message
        let userMessage = ChatMessage(content: messageText, isUser: true)
        messages.append(userMessage)

        let currentMessage = messageText
        messageText = ""
        scrollToBottom = true

        // Simulate AI processing
        isTyping = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false

            // Generate AI response based on context
            if let quickAction = selectedQuickAction {
                // Generate notification message
                generatedMessage = generateNotificationMessage(
                    for: quickAction,
                    with: currentMessage
                )

                let aiResponse = ChatMessage(
                    content: "I've prepared your notification message. Let me show you the preview:",
                    isUser: false
                )
                messages.append(aiResponse)
                scrollToBottom = true

                // Show preview after brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingMessagePreview = true
                }

            } else {
                // Regular conversation response
                let aiResponse = ChatMessage(
                    content: "I understand you want to: \(currentMessage). How would you like me to help you with this?",
                    isUser: false
                )
                messages.append(aiResponse)
                scrollToBottom = true
            }
        }
    }

    private func generateNotificationMessage(for action: QuickAction, with details: String) -> String {
        let greeting: String
        let closing: String
        var body = ""

        switch action {
        case .practiceCancelled, .gameTimeChange, .tournamentInfo, .urgentUpdate:
            greeting = "Dear Express Basketball Families,"
            closing = "\n\nThank you for your understanding.\n\nCoach"

            switch action {
            case .practiceCancelled:
                body = "Today's practice has been cancelled. \(details)\n\nOur next scheduled practice will be communicated shortly."
            case .gameTimeChange:
                body = "Please note that our game time has been changed. \(details)\n\nPlease adjust your schedules accordingly."
            case .tournamentInfo:
                body = "Important tournament information: \(details)\n\nPlease mark your calendars."
            case .urgentUpdate:
                body = "URGENT: \(details)\n\nPlease acknowledge receipt of this message."
            case .practiceTips, .gamePlan, .drillSuggestion, .playerMotivation:
                break // These cases are handled in other branches
            }

        case .practiceTips:
            greeting = "Team,"
            closing = "\n\nLet's work hard and improve together!\n\nCoach"
            body = """
            Here's our practice focus for this week:

            🏀 FUNDAMENTALS (20 min)
            • Ball handling: Stationary dribbling, crossovers, between legs
            • Passing: Chest pass, bounce pass, overhead pass drills

            🛡️ DEFENSE (25 min)
            • Defensive slides and footwork
            • Closeout drills
            • Help defense positioning
            • 3-on-3 shell drill

            🎯 SHOOTING (20 min)
            • Form shooting close to basket
            • Spot shooting from 5 positions
            • Free throw routine (make 10 in a row)

            🏃 CONDITIONING (15 min)
            • Suicide runs
            • Defensive slide intervals
            • Full court layup lines
            """

        case .gamePlan:
            greeting = "Team,"
            closing = "\n\nBring your energy and execute!\n\nCoach"
            body = """
            Game Strategy for Next Opponent:

            📋 OFFENSIVE KEYS
            • Run motion offense with quick ball movement
            • Attack the paint early in possessions
            • Set good screens and cut hard
            • Crash offensive boards - second chance points

            🛡️ DEFENSIVE PLAN
            • Man-to-man pressure defense
            • Force to weak hand
            • Help and recover on drives
            • Box out on every shot
            • Communicate on screens

            🎯 FOCUS POINTS
            • First 5 minutes set the tone with energy
            • Take care of the ball - limit turnovers
            • Sprint back on defense
            • Encourage teammates constantly
            """

        case .drillSuggestion:
            greeting = "Players,"
            closing = "\n\nPractice these at home!\n\nCoach"
            body = """
            Ball Handling & Defense Drills to Practice:

            🏀 DRIBBLING DRILLS (Do each for 30 seconds)
            1. Stationary pound dribble (both hands)
            2. Figure 8 around legs
            3. Spider dribble (front to back)
            4. Crossover series (sitting and standing)
            5. Two-ball dribbling (simultaneous and alternating)

            🛡️ DEFENSIVE POSITIONING
            1. Defensive slides (3 sets of 30 seconds)
            2. Close-out drill to mirror
            3. Lane slides (zigzag pattern)

            💪 Do these drills daily for 15-20 minutes to see improvement!
            """

        case .playerMotivation:
            greeting = "Team,"
            closing = "\n\nProud of you all!\n\nCoach"
            body = """
            Remember why we play this game:

            🌟 TEAMWORK makes us stronger than individuals
            • Support each other on and off the court
            • Celebrate teammates' successes
            • Pick each other up after mistakes

            💪 EFFORT is what we can always control
            • Give 100% every practice and game
            • Push through when it gets tough
            • Your effort inspires others

            📈 IMPROVEMENT happens daily
            • Every drill makes you better
            • Learn from mistakes
            • Compare yourself to yesterday's you

            You're becoming not just better players, but better people. Keep working hard!
            """
        }

        return "\(greeting)\n\n\(body)\(closing)"
    }

    private func finalizeAndSend() {
        let successMessage = ChatMessage(
            content: "✅ Message sent successfully to \(formatRecipients())!",
            isUser: false
        )
        messages.append(successMessage)

        // Reset state
        selectedQuickAction = nil
        selectedRecipients.removeAll()
        generatedMessage = ""
        showingMessagePreview = false
        scrollToBottom = true
    }

    private func formatRecipients() -> String {
        if selectedRecipients.isEmpty {
            return "selected recipients"
        }
        return selectedRecipients.map { $0.rawValue }.joined(separator: ", ")
    }

    private func clearChat() {
        messages.removeAll()
        selectedQuickAction = nil
        selectedRecipients.removeAll()
        setupInitialMessages()
    }
}

// MARK: - Supporting Views

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                Text("AI Assistant Coach")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Choose a quick action below or type your message")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
    }
}

struct QuickActionsGrid: View {
    @Binding var selectedAction: PerplexityStyleAssistantView.QuickAction?
    let onActionTapped: (PerplexityStyleAssistantView.QuickAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.primary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(PerplexityStyleAssistantView.QuickAction.allCases) { action in
                    PerplexityQuickActionButton(
                        action: action,
                        isSelected: selectedAction == action
                    ) {
                        onActionTapped(action)
                    }
                }
            }
        }
    }
}

struct PerplexityQuickActionButton: View {
    let action: PerplexityStyleAssistantView.QuickAction
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? action.color : Color(.systemGray6))
                        .frame(width: 56, height: 56)

                    Image(systemName: action.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : action.color)
                }

                Text(action.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MessageBubble: View {
    let message: PerplexityStyleAssistantView.ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !message.isUser {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if let quickAction = message.quickAction {
                    HStack(spacing: 4) {
                        Image(systemName: quickAction.icon)
                            .font(.caption)
                        Text(quickAction.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(quickAction.color)
                }

                Text(message.content)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.isUser ? Color.blue : Color(.systemGray6)
                    )
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(18)
                    .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if message.isUser {
                // User Avatar
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 32, height: 32)

                    Text("C")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
        .padding(.horizontal)
    }
}

struct PerplexityTypingIndicator: View {
    @State private var animationAmount = 0.0

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)

                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }

            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationAmount)
                        .opacity(animationAmount)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationAmount
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(18)
            .frame(maxWidth: 80, alignment: .leading)

            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            animationAmount = 1.0
        }
    }
}

struct InputAreaView: View {
    @Binding var messageText: String
    @Binding var selectedRecipients: Set<PerplexityStyleAssistantView.RecipientType>
    @FocusState var isInputFocused: Bool
    let onSend: () -> Void
    let onRecipientsToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Recipients chips
            if !selectedRecipients.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(selectedRecipients)) { recipient in
                            PerplexityRecipientChip(
                                recipient: recipient,
                                onRemove: {
                                    selectedRecipients.remove(recipient)
                                }
                            )
                        }

                        Button(action: onRecipientsToggle) {
                            Label("Add", systemImage: "plus.circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                Divider()
            }

            // Input field and buttons
            HStack(spacing: 12) {
                // Attachment button
                Button(action: {}) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }

                // Search button
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }

                // Text field
                TextField("Ask anything...", text: $messageText, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.body)
                    .lineLimit(1...4)
                    .focused($isInputFocused)
                    .onSubmit {
                        onSend()
                    }

                // Recipients button
                Button(action: onRecipientsToggle) {
                    Image(systemName: selectedRecipients.isEmpty ? "person.crop.circle" : "person.crop.circle.badge.checkmark")
                        .font(.system(size: 20))
                        .foregroundColor(selectedRecipients.isEmpty ? .gray : .blue)
                }

                // Microphone button
                Button(action: {}) {
                    Image(systemName: "mic")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }

                // Send button
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
}

struct PerplexityRecipientChip: View {
    let recipient: PerplexityStyleAssistantView.RecipientType
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: recipient.icon)
                .font(.caption2)

            Text(recipient.rawValue)
                .font(.caption)
                .fontWeight(.medium)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(recipient.color.opacity(0.15))
        .foregroundColor(recipient.color)
        .cornerRadius(14)
    }
}

struct RecipientSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedRecipients: Set<PerplexityStyleAssistantView.RecipientType>

    var body: some View {
        NavigationStack {
            List {
                Section("Select Recipients") {
                    ForEach(PerplexityStyleAssistantView.RecipientType.allCases) { recipient in
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

struct MessagePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let message: String
    let recipients: Set<PerplexityStyleAssistantView.RecipientType>
    let onSend: () -> Void
    let onEdit: () -> Void

    @State private var editedMessage: String = ""
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Recipients
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recipients")
                            .font(.headline)

                        PerplexityFlowLayout(spacing: 8) {
                            ForEach(Array(recipients)) { recipient in
                                HStack(spacing: 4) {
                                    Image(systemName: recipient.icon)
                                        .font(.caption)
                                    Text(recipient.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(recipient.color.opacity(0.15))
                                .foregroundColor(recipient.color)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    // Message
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Message")
                                .font(.headline)

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
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        } else {
                            Text(editedMessage.isEmpty ? message : editedMessage)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("Review & Send")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
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
            editedMessage = message
        }
    }
}

// MARK: - Flow Layout

struct PerplexityFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
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

// MARK: - Preview

#Preview {
    PerplexityStyleAssistantView()
        .modelContainer(for: [Team.self])
}