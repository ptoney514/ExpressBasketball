//
//  ChatView.swift
//  ExpressCoach
//
//  Chat/messaging view for team communication
//

import SwiftUI
import SwiftData
import AVFoundation
import AVFAudio
import Combine

struct ChatView: View {
    @Query private var teams: [Team]
    @State private var selectedTeam: Team?
    @State private var searchText = ""
    @State private var showingVoiceAssistant = false
    @State private var showingAllTeamsMessage = false
    @State private var messageText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // All Teams Option
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Send to All")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            AllTeamsRowView()
                                .onTapGesture {
                                    showingAllTeamsMessage = true
                                }
                        }
                        .padding(.top)
                        
                        // Team Chats
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Team Chats")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(teams) { team in
                                ChatRowView(team: team)
                                    .onTapGesture {
                                        selectedTeam = team
                                    }
                            }
                        }
                        
                        // Recent Messages Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Messages")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            MessagePreviewRow(
                                title: "Practice Reminder",
                                message: "Don't forget practice tomorrow at 6 PM",
                                time: "2 hours ago",
                                isUnread: true
                            )
                            
                            MessagePreviewRow(
                                title: "Game Schedule Update",
                                message: "Saturday's game moved to 2 PM",
                                time: "Yesterday",
                                isUnread: false
                            )
                        }
                        .padding(.top)
                    }
                    .padding(.bottom, 100) // Space for FAB
                }
                
                // Floating Action Button for Voice Assistant
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingMicrophoneButton {
                            showingVoiceAssistant = true
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color("BasketballOrange"))
                    }
                }
            }
            .sheet(item: $selectedTeam) { team in
                TeamChatView(team: team)
            }
            .sheet(isPresented: $showingAllTeamsMessage) {
                AllTeamsMessageComposer()
            }
            .fullScreenCover(isPresented: $showingVoiceAssistant) {
                VoiceAssistantView(messageText: $messageText, onComplete: {
                    showingVoiceAssistant = false
                    if !messageText.isEmpty {
                        // Handle the AI-generated message
                        showingAllTeamsMessage = true
                    }
                })
            }
        }
        .preferredColorScheme(.dark)
    }
}

// All Teams Row
struct AllTeamsRowView: View {
    var body: some View {
        HStack(spacing: 12) {
            // All Teams Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("BasketballOrange"), Color("BasketballOrange").opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("All Teams")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Send a message to all your teams")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [Color("CoachBlack"), Color("BackgroundDark")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("BasketballOrange").opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Floating Microphone Button
struct FloatingMicrophoneButton: View {
    let action: () -> Void
    @State private var isPressed = false
    @State private var pulseAnimation = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Pulse effect
                Circle()
                    .fill(Color("BasketballOrange").opacity(0.3))
                    .frame(width: 80, height: 80)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .opacity(pulseAnimation ? 0 : 0.5)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: pulseAnimation
                    )
                
                // Main button
                Circle()
                    .fill(Color("BasketballOrange"))
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Microphone icon
                VStack(spacing: 2) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("AI")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .onLongPressGesture(minimumDuration: 0.0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            pulseAnimation = true
        }
    }
}

// Voice Assistant View States
enum AssistantState {
    case idle           // Initial state with greeting
    case recording      // Actively recording voice
    case processing     // AI is processing
    case result        // Showing generated message
}

// Example Prompt Model
struct ExamplePrompt: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let mockTranscription: String
    let mockResponse: String
}

// Voice Assistant View
struct VoiceAssistantView: View {
    @Binding var messageText: String
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var assistantState: AssistantState = .idle
    @State private var audioLevel: Float = 0
    @State private var transcribedText = ""
    @State private var aiGeneratedMessage = ""
    @State private var animationTimer: Timer?
    @State private var processingProgress: Double = 0
    @State private var selectedPrompt: ExamplePrompt?
    // MOCK: Disable audio recorder temporarily for TestFlight
    // @StateObject private var audioRecorder = AudioRecorderManager()
    
    // Example prompts
    let examplePrompts = [
        ExamplePrompt(
            icon: "xmark.circle.fill",
            title: "Cancel Practice",
            subtitle: "Tell the team practice today at 5 is cancelled",
            mockTranscription: "Cancel today's practice at 5 PM",
            mockResponse: """
📢 Practice Update - CANCELLED

Team,

Today's practice at 5:00 PM is cancelled due to unforeseen circumstances.

We'll resume our regular schedule tomorrow. Use this time to rest and recover.

Stay ready! 💪

Coach
"""
        ),
        ExamplePrompt(
            icon: "tshirt.fill",
            title: "Uniform Reminder",
            subtitle: "Remind players to bring their uniforms tomorrow",
            mockTranscription: "Remind everyone to bring uniforms for tomorrow's game",
            mockResponse: """
🏀 Game Day Reminder!

Team,

Don't forget to bring your FULL UNIFORM for tomorrow's game:

✅ Game jersey (Home/White)
✅ Game shorts
✅ Team warm-ups
✅ Basketball shoes
✅ Water bottle

Game time: 3:00 PM
Arrive by: 2:15 PM for warm-ups

Let's show up prepared and ready to compete! 🔥

Coach
"""
        ),
        ExamplePrompt(
            icon: "calendar.badge.plus",
            title: "Schedule Meeting",
            subtitle: "Schedule a team meeting for Saturday at 3pm",
            mockTranscription: "Schedule team meeting Saturday 3 PM",
            mockResponse: """
📅 Team Meeting - Saturday

Team & Parents,

We'll be having an important team meeting this Saturday.

📍 When: Saturday, 3:00 PM - 4:00 PM
📍 Where: Main Gym Conference Room
📍 Who: All players and at least one parent/guardian

Topics to cover:
• Upcoming tournament schedule
• Team goals for the season
• Fundraising updates
• Q&A session

Please confirm your attendance by replying to this message.

See you there!

Coach
"""
        ),
        ExamplePrompt(
            icon: "flame.fill",
            title: "Game Day Motivation",
            subtitle: "Send a game day motivation message",
            mockTranscription: "Send game day motivation to get the team pumped",
            mockResponse: """
🔥 GAME DAY! 🔥

Team,

Today is OUR day! We've worked hard, practiced with purpose, and now it's time to show what Express Basketball is all about!

Remember:
💪 Trust your training
🎯 Execute our game plan
🤝 Play for each other
🏀 Have FUN out there!

"Champions are made from something they have deep inside them - a desire, a dream, a vision."

Let's bring that ENERGY and PASSION to the court today!

SEE YOU ON THE COURT! LET'S GO EXPRESS! 🚀

Coach
"""
        )
    ]
    
    var body: some View {
        ZStack {
            // Dark background with gradient
            LinearGradient(
                colors: [Color("BackgroundDark"), Color("CoachBlack")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            switch assistantState {
            case .idle:
                // Welcome screen with example prompts
                IdleAssistantView(
                    examplePrompts: examplePrompts,
                    onPromptSelected: handlePromptSelection,
                    onMicrophoneTap: startRecording
                )
                .transition(.opacity)
                
            case .recording:
                // Recording Interface
                RecordingAssistantView(
                    audioLevel: audioLevel,
                    transcribedText: transcribedText,
                    onStop: stopRecording,
                    onCancel: cancelRecording
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
                
            case .processing:
                // Processing state
                ProcessingAssistantView(progress: processingProgress)
                    .transition(.opacity)
                
            case .result:
                // Result Interface
                ResultAssistantView(
                    transcribedText: transcribedText,
                    generatedMessage: $aiGeneratedMessage,
                    onUseMessage: useMessage,
                    onRecordAgain: resetToIdle,
                    onEdit: {}
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .preferredColorScheme(.dark)
        .onDisappear {
            cleanupRecording()
        }
    }
    
    // MARK: - Helper Methods
    
    private func handlePromptSelection(_ prompt: ExamplePrompt) {
        selectedPrompt = prompt
        transcribedText = prompt.mockTranscription
        aiGeneratedMessage = prompt.mockResponse
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Simulate processing
        withAnimation(.easeInOut(duration: 0.3)) {
            assistantState = .processing
        }
        
        simulateProcessing()
    }
    
    private func startRecording() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            assistantState = .recording
        }
        
        // MOCK: Skip actual audio recording for now
        // audioRecorder.startRecording()
        simulateAudioLevels()
        
        // Simulate transcription after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            transcribedText = "Send a reminder about tomorrow's practice at 6 PM"
        }
    }
    
    private func stopRecording() {
        // MOCK: Skip actual audio recording for now
        // audioRecorder.stopRecording()
        animationTimer?.invalidate()
        audioLevel = 0
        
        // Process the recording
        withAnimation(.easeInOut(duration: 0.3)) {
            assistantState = .processing
        }
        
        // Generate contextual message based on transcription
        generateContextualMessage()
        simulateProcessing()
    }
    
    private func cancelRecording() {
        cleanupRecording()
        dismiss()
    }
    
    private func cleanupRecording() {
        // MOCK: Skip actual audio recording for now
        // audioRecorder.stopRecording()
        animationTimer?.invalidate()
        animationTimer = nil
        audioLevel = 0
    }
    
    private func resetToIdle() {
        transcribedText = ""
        aiGeneratedMessage = ""
        selectedPrompt = nil
        processingProgress = 0
        
        withAnimation(.easeInOut(duration: 0.3)) {
            assistantState = .idle
        }
    }
    
    private func useMessage() {
        messageText = aiGeneratedMessage
        
        // Add success haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        onComplete()
    }
    
    private func simulateProcessing() {
        processingProgress = 0
        
        // Animate progress
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if processingProgress < 1.0 {
                processingProgress += 0.05
            } else {
                timer.invalidate()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    assistantState = .result
                }
            }
        }
    }
    
    private func simulateAudioLevels() {
        animationTimer?.invalidate()
        
        // MOCK: Always use simulated levels for now
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                if self.assistantState == .recording {
                    self.audioLevel = Float.random(in: 0.1...0.8)
                } else {
                    self.audioLevel = 0
                }
            }
        }
    }
    
    private func generateContextualMessage() {
        let lowercased = transcribedText.lowercased()
        
        if lowercased.contains("cancel") || lowercased.contains("cancelled") {
            aiGeneratedMessage = examplePrompts[0].mockResponse
        } else if lowercased.contains("uniform") || lowercased.contains("jersey") {
            aiGeneratedMessage = examplePrompts[1].mockResponse
        } else if lowercased.contains("meeting") || lowercased.contains("schedule") {
            aiGeneratedMessage = examplePrompts[2].mockResponse
        } else if lowercased.contains("motivation") || lowercased.contains("pump") || lowercased.contains("game day") {
            aiGeneratedMessage = examplePrompts[3].mockResponse
        } else if lowercased.contains("practice") || lowercased.contains("reminder") {
            // Default practice reminder
            aiGeneratedMessage = """
🏀 Practice Reminder

Team,

Just a reminder about tomorrow's practice:

📍 Location: Main Gym
⏰ Time: 6:00 PM - 8:00 PM

Please bring:
• Water bottle
• Basketball shoes
• Practice jersey
• Positive attitude!

If you can't make it, please let me know ASAP.

Let's have a great practice! 💪

Coach
"""
        } else {
            // Generic team message
            aiGeneratedMessage = """
📢 Team Update

Team,

\(transcribedText)

Please reach out if you have any questions.

Thanks,
Coach
"""
        }
    }
}

// MARK: - Sub-views for different states

struct IdleAssistantView: View {
    let examplePrompts: [ExamplePrompt]
    let onPromptSelected: (ExamplePrompt) -> Void
    let onMicrophoneTap: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var greetingOpacity = 0.0
    @State private var promptsOpacity = 0.0
    @State private var buttonScale = 0.8
    
    var body: some View {
        VStack(spacing: 32) {
            // Close button at top
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .padding(.trailing, 20)
                .padding(.top, 20)
            }
            
            Spacer()
            
            // Assistant greeting
            VStack(spacing: 12) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color("BasketballOrange"))
                    // .symbolEffect(.pulse) // iOS 18+ only
                    .scaleEffect(greetingOpacity)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: greetingOpacity)
                
                Text("What can I help you with today, Coach?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("I can help you compose messages for your team")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .opacity(greetingOpacity)
            
            // Example prompts
            VStack(spacing: 12) {
                Text("Try saying:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ForEach(examplePrompts) { prompt in
                    ExamplePromptCard(prompt: prompt) {
                        onPromptSelected(prompt)
                    }
                }
            }
            .padding(.horizontal)
            .opacity(promptsOpacity)
            
            Spacer()
            
            // Microphone button
            Button(action: onMicrophoneTap) {
                ZStack {
                    Circle()
                        .fill(Color("BasketballOrange"))
                        .frame(width: 80, height: 80)
                        .shadow(color: Color("BasketballOrange").opacity(0.3), radius: 10)
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .scaleEffect(buttonScale)
            .padding(.bottom, 50)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                greetingOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                promptsOpacity = 1
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4)) {
                buttonScale = 1
            }
        }
    }
}

struct ExamplePromptCard: View {
    let prompt: ExamplePrompt
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: prompt.icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color("BasketballOrange"))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(prompt.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text("\"\(prompt.subtitle)\"")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .italic()
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color("CoachBlack"))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
        }
    }
}

struct RecordingAssistantView: View {
    let audioLevel: Float
    let transcribedText: String
    let onStop: () -> Void
    let onCancel: () -> Void
    
    @State private var waveAmplitudes: [CGFloat] = Array(repeating: 0.5, count: 30)
    @State private var waveTimer: Timer?
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Status
            VStack(spacing: 8) {
                Text("Listening...")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Speak clearly about your message")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Sound wave visualization
            HStack(spacing: 3) {
                ForEach(0..<waveAmplitudes.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color("BasketballOrange"))
                        .frame(width: 3, height: 20 * waveAmplitudes[index])
                }
            }
            .frame(height: 60)
            .onAppear {
                startWaveAnimation()
            }
            .onDisappear {
                waveTimer?.invalidate()
            }
            
            // Stop button
            Button(action: onStop) {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "stop.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            // Live transcription
            if !transcribedText.isEmpty {
                VStack(spacing: 8) {
                    Text("Hearing:")
                        .font(.caption)
                        .foregroundColor(Color("BasketballOrange"))
                    
                    Text(transcribedText)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .transition(.opacity)
            }
            
            Spacer()
            
            // Cancel button
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
    }
    
    private func startWaveAnimation() {
        waveTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                // Shift waves and add new random amplitude
                waveAmplitudes.removeFirst()
                waveAmplitudes.append(CGFloat.random(in: 0.2...1.0))
            }
        }
    }
}

struct ProcessingAssistantView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // AI thinking animation
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color("BasketballOrange").opacity(0.3), lineWidth: 2)
                        .frame(width: 60 + CGFloat(index * 20), height: 60 + CGFloat(index * 20))
                        .scaleEffect(1 + progress * 0.5)
                        .opacity(1 - progress)
                }
                
                Image(systemName: "brain")
                    .font(.system(size: 40))
                    .foregroundColor(Color("BasketballOrange"))
                    .scaleEffect(1.0 + progress * 0.2)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: progress)
            }
            
            VStack(spacing: 8) {
                Text("AI is thinking...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Creating the perfect message for your team")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            // Progress bar
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color("BasketballOrange")))
                .frame(width: 200)
            
            Spacer()
        }
        .padding()
    }
}

struct ResultAssistantView: View {
    let transcribedText: String
    @Binding var generatedMessage: String
    let onUseMessage: () -> Void
    let onRecordAgain: () -> Void
    let onEdit: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Close button at top right
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Success indicator
                ZStack {
                    Circle()
                        .fill(Color("CourtGreen").opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color("CourtGreen"))
                        // .symbolEffect(.bounce) // iOS 18+ only
                }
                .padding(.top, 20)
                
                Text("Perfect! Here's your message")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Original request
                if !transcribedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("You asked for:", systemImage: "mic.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(transcribedText)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                // AI-generated message
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Your Message:", systemImage: "sparkles")
                            .font(.caption)
                            .foregroundColor(Color("BasketballOrange"))
                        
                        Spacer()
                        
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(Color("BasketballOrange"))
                        }
                    }
                    
                    TextEditor(text: $generatedMessage)
                        .font(.body)
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .frame(minHeight: 200)
                        .background(Color("CoachBlack"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("BasketballOrange").opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onUseMessage) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Send This Message")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("BasketballOrange"))
                        .cornerRadius(12)
                    }
                    
                    Button(action: onRecordAgain) {
                        HStack {
                            Image(systemName: "mic.fill")
                            Text("Try Again")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
}

// All Teams Message Composer
struct AllTeamsMessageComposer: View {
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var selectedTemplate = "custom"
    @Query private var teams: [Team]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Teams that will receive the message
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Sending to \(teams.count) teams", systemImage: "person.3.fill")
                            .font(.subheadline)
                            .foregroundColor(Color("BasketballOrange"))
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(teams) { team in
                                    TeamChip(name: team.name)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Message composer
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Message")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        TextEditor(text: $message)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color("CoachBlack"))
                            .cornerRadius(12)
                            .frame(minHeight: 200)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Message All Teams")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        // Send message logic
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Color("BasketballOrange"))
                    .disabled(message.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Team Chip View
struct TeamChip: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color("BasketballOrange").opacity(0.3))
            .cornerRadius(15)
    }
}

// MOCK: Audio Recorder Manager disabled temporarily for TestFlight
// TODO: Re-enable after adding NSMicrophoneUsageDescription to Info.plist
/*
@MainActor
class AudioRecorderManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession?
    private var levelTimer: Timer?
    private let recordingQueue = DispatchQueue(label: "com.expresscoach.audiorecording", qos: .userInitiated)
    
    override init() {
        super.init()
        Task {
            await setupRecordingSession()
        }
    }
    
    deinit {
        // Clean up on deinit - must handle main actor isolation
        levelTimer?.invalidate()
        levelTimer = nil
        if let recorder = audioRecorder {
            recordingQueue.async { [weak recorder] in
                recorder?.stop()
            }
        }
    }
    
    private func setupRecordingSession() async {
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            // Configure audio session on a background queue
            try audioSession?.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try audioSession?.setActive(true)
            
            // Request permission
            if #available(iOS 17.0, *) {
                let allowed = await AVAudioApplication.requestRecordPermission()
                if !allowed {
                    print("Recording permission denied")
                }
            } else {
                // Fallback for older versions
                await withCheckedContinuation { continuation in
                    AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                        if !allowed {
                            print("Recording permission denied")
                        }
                        continuation.resume()
                    }
                }
            }
        } catch {
            print("Failed to set up recording session: \(error)")
        }
    }
    
    func startRecording() {
        // Ensure we're on main thread
        Task { @MainActor in
            await performStartRecording()
        }
    }
    
    @MainActor
    private func performStartRecording() async {
        // Clean up any existing recording
        cleanup()
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000
        ]
        
        do {
            // Create recorder on main thread
            let recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            
            audioRecorder = recorder
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.delegate = self
            
            // Start recording
            let success = recorder.record()
            
            if success {
                isRecording = true
                startMetering()
            } else {
                print("Failed to start recording")
            }
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    @MainActor
    private func startMetering() {
        levelTimer?.invalidate()
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor [weak self] in
                guard let self = self, self.isRecording else { return }
                await self.updateAudioLevel()
            }
        }
    }
    
    @MainActor
    private func updateAudioLevel() async {
        guard let recorder = audioRecorder, isRecording else { return }
        
        // Update meters on main thread since we're already on MainActor
        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)
        audioLevel = normalizeAudioLevel(averagePower)
    }
    
    func stopRecording() {
        Task { @MainActor in
            cleanup()
        }
    }
    
    @MainActor
    private func cleanup() {
        levelTimer?.invalidate()
        levelTimer = nil
        
        if let recorder = audioRecorder {
            recordingQueue.async { [weak recorder] in
                recorder?.stop()
            }
        }
        
        audioRecorder = nil
        isRecording = false
        audioLevel = 0.0
    }
    
    private func normalizeAudioLevel(_ level: Float) -> Float {
        let minDb: Float = -60
        let maxDb: Float = 0
        
        let clampedLevel = max(minDb, min(level, maxDb))
        return (clampedLevel - minDb) / (maxDb - minDb)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
*/

// MARK: - AVAudioRecorderDelegate
/*
extension AudioRecorderManager: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            if flag {
                print("Recording finished successfully")
            } else {
                print("Recording failed")
            }
            cleanup()
        }
    }
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor in
            print("Recording error: \(error?.localizedDescription ?? "Unknown error")")
            cleanup()
        }
    }
}
*/

struct ChatRowView: View {
    let team: Team
    
    var body: some View {
        HStack(spacing: 12) {
            // Team Avatar
            ZStack {
                Circle()
                    .fill(Color("BasketballOrange").opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(team.name.prefix(2).uppercased())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color("BasketballOrange"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Tap to open team chat")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Now")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                // Unread badge
                Circle()
                    .fill(Color("BasketballOrange"))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text("3")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color("CoachBlack"))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MessagePreviewRow: View {
    let title: String
    let message: String
    let time: String
    let isUnread: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnread ? Color("BasketballOrange").opacity(0.2) : Color.gray.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 18))
                    .foregroundColor(isUnread ? Color("BasketballOrange") : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(isUnread ? .semibold : .medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            if isUnread {
                Circle()
                    .fill(Color("BasketballOrange"))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct TeamChatView: View {
    let team: Team
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()
                
                VStack {
                    Text("Team Chat")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text(team.name)
                        .font(.headline)
                        .foregroundColor(Color("BasketballOrange"))
                    
                    Spacer()
                    
                    Text("Chat interface coming soon")
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(team.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("BasketballOrange"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ChatView()
        .preferredColorScheme(.dark)
}