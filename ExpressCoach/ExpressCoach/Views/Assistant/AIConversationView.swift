//
//  AIConversationView.swift
//  ExpressCoach
//
//  Created on 9/21/25.
//

import SwiftUI
import SwiftData

struct AIConversationView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var teams: [Team]
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false

    var currentTeam: Team? {
        teams.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Chat messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 16) {
                                // Welcome message
                                ChatBubble(
                                    message: "Hi Coach! I'm here to help with practice plans, team management, and parent communications. What can I assist you with today?",
                                    isUser: false,
                                    showAvatar: true
                                )

                                ForEach(messages) { message in
                                    ChatBubble(
                                        message: message.text,
                                        isUser: message.isUser,
                                        showAvatar: !message.isUser
                                    )
                                }

                                if isLoading {
                                    HStack {
                                        AIConversationTypingIndicator()
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding()
                            .id("bottom")
                        }
                        .onChange(of: messages.count) { _, _ in
                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }

                    // Input area
                    HStack(spacing: 12) {
                        TextField("Ask me anything...", text: $messageText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color("CoachBlack"))
                            .cornerRadius(20)
                            .lineLimit(1...4)

                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(messageText.isEmpty ? .gray : Color("BasketballOrange"))
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding()
                    .background(Color("BackgroundDark"))
                }
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("BasketballOrange"))
                }
            }
        }
    }

    private func sendMessage() {
        let userMessage = ChatMessage(text: messageText, isUser: true)
        messages.append(userMessage)

        let query = messageText
        messageText = ""
        isLoading = true

        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let response = generateAIResponse(for: query)
            messages.append(ChatMessage(text: response, isUser: false))
            isLoading = false
        }
    }

    private func generateAIResponse(for query: String) -> String {
        // Simplified AI responses for demo
        if query.lowercased().contains("practice") {
            return "Here's a suggested practice plan for today:\n\n1. Warm-up (10 mins): Dynamic stretching and light jogging\n2. Ball handling drills (15 mins): Stationary and moving dribbling\n3. Shooting practice (20 mins): Form shooting and game-speed shots\n4. Team plays (20 mins): Work on offensive sets\n5. Scrimmage (20 mins): 5v5 game situations\n6. Cool down (5 mins): Static stretching\n\nWould you like me to adjust this based on your team's needs?"
        } else if query.lowercased().contains("parent") || query.lowercased().contains("message") {
            return "I can help you draft a message to parents. What would you like to communicate? Some common topics:\n\n• Practice schedule changes\n• Game day reminders\n• Equipment needs\n• Team fundraising\n• Player achievements\n\nJust let me know the topic and I'll help you write a clear, professional message."
        } else if query.lowercased().contains("player") || query.lowercased().contains("improve") {
            return "Based on your team's recent performance, here are some areas to focus on:\n\n1. **Defense**: Work on closeout drills and help-side positioning\n2. **Passing**: Emphasize decision-making under pressure\n3. **Conditioning**: Add more transition drills\n\nWould you like specific drills for any of these areas?"
        } else {
            return "I understand you're asking about \"\(query)\". I can help with:\n\n• Practice planning and drills\n• Parent communication drafts\n• Game strategies\n• Player development tips\n• Schedule management\n\nHow can I assist you specifically?"
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: String
    let isUser: Bool
    let showAvatar: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !isUser && showAvatar {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 32, height: 32)

                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message)
                    .padding(12)
                    .background(
                        isUser ?
                        AnyView(Color("BasketballOrange")) :
                        AnyView(Color("CoachBlack"))
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
            }

            if isUser {
                Spacer(minLength: 60)
            } else {
                Spacer()
            }
        }
    }
}

struct AIConversationTypingIndicator: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationPhase == index ? 1.3 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: animationPhase
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color("CoachBlack"))
        .cornerRadius(16)
        .onAppear {
            animationPhase = 0
            withAnimation {
                animationPhase = 2
            }
        }
    }
}

#Preview {
    AIConversationView()
        .modelContainer(for: [Team.self])
}