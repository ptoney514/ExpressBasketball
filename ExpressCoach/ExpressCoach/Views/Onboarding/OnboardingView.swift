import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    @State private var dragOffset: CGSize = .zero
    let totalPages = 7

    var body: some View {
        ZStack {
            // Dynamic gradient background
            AnimatedGradientBackground()

            // Floating particles
            ParticleEffectView()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)

                    AICoachFeaturePage()
                        .tag(1)

                    InstantCommunicationPage()
                        .tag(2)

                    SmartSchedulingPage()
                        .tag(3)

                    RosterManagementPage()
                        .tag(4)

                    RealTimeSyncPage()
                        .tag(5)

                    GetStartedPage(onGetStarted: {
                        // Complete onboarding
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            onComplete()
                        }
                    })
                    .tag(6)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .offset(x: dragOffset.width)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.interactiveSpring()) {
                                dragOffset = value.translation
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                dragOffset = .zero
                            }
                        }
                )

                // Custom page indicator with progress
                EnhancedPageIndicator(currentPage: currentPage, totalPages: totalPages)
                    .padding(.bottom, 20)

                // Next button with enhanced styling
                if currentPage < totalPages - 1 {
                    NextButton(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    })
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled()
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    @State private var isAnimating = false
    @State private var pulseAnimation = false
    @State private var textAppear = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Animated logo with multiple layers
            ZStack {
                // Outer pulse rings
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color("BasketballOrange").opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 250 + CGFloat(index * 50), height: 250 + CGFloat(index * 50))
                        .scaleEffect(pulseAnimation ? 1.1 : 0.9)
                        .opacity(pulseAnimation ? 0 : 0.6)
                        .animation(
                            Animation.easeOut(duration: 2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                            value: pulseAnimation
                        )
                }

                // Glowing orb background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("BasketballOrange").opacity(0.4),
                                Color("BasketballOrange").opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 20)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 3)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                // Basketball icon with rotation
                ZStack {
                    Image(systemName: "basketball.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color("BasketballOrange"),
                                    Color("BasketballOrange").opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 20)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )

                    // Inner glow
                    Image(systemName: "basketball.fill")
                        .font(.system(size: 100))
                        .foregroundColor(Color("BasketballOrange"))
                        .blur(radius: 10)
                        .opacity(0.6)
                }
            }

            // Animated text content
            VStack(spacing: 20) {
                Text("Welcome to")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(textAppear ? 1 : 0)
                    .offset(y: textAppear ? 0 : 20)

                HStack(spacing: 0) {
                    Text("Express")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color("BasketballOrange"),
                                    Color("BasketballOrange").opacity(0.8),
                                    Color.orange
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Coach")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color.white.opacity(0.9)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .shadow(color: Color("BasketballOrange").opacity(0.5), radius: 20, x: 0, y: 10)
                .scaleEffect(textAppear ? 1 : 0.8)
                .opacity(textAppear ? 1 : 0)

                Text("Revolutionizing Youth Basketball Management")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white.opacity(0.8), Color.white.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, 40)
                    .opacity(textAppear ? 1 : 0)
                    .offset(y: textAppear ? 0 : 20)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: textAppear)

            Spacer()
            Spacer()
        }
        .onAppear {
            isAnimating = true
            pulseAnimation = true
            withAnimation(.easeOut(duration: 0.8)) {
                textAppear = true
            }
        }
    }
}

// MARK: - AI Coach Feature Page
struct AICoachFeaturePage: View {
    @State private var isVisible = false
    @State private var brainPulse = false
    @State private var dataPoints: [DataPoint] = []

    struct DataPoint: Identifiable {
        let id = UUID()
        let position: CGPoint
        let delay: Double
    }

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // AI Brain Animation
            ZStack {
                // Neural network connections
                ForEach(0..<6) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.6), Color.blue.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(Double(index) * 60))
                        .scaleEffect(brainPulse ? 1.2 : 1.0)
                        .opacity(brainPulse ? 0.3 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.1),
                            value: brainPulse
                        )
                }

                // Glowing core
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.cyan.opacity(0.8),
                                Color.blue.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 10)
                    .scaleEffect(brainPulse ? 1.3 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: brainPulse
                    )

                // AI Icon
                Image(systemName: "brain")
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isVisible ? 1 : 0.5)
                    .rotationEffect(.degrees(isVisible ? 0 : -180))
                    .shadow(color: Color.cyan.opacity(0.8), radius: 20)

                // Floating data particles
                ForEach(dataPoints) { point in
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 4, height: 4)
                        .position(point.position)
                        .opacity(isVisible ? 0 : 1)
                        .animation(
                            Animation.easeOut(duration: 2)
                                .delay(point.delay),
                            value: isVisible
                        )
                }
            }
            .frame(width: 200, height: 200)
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isVisible)

            VStack(spacing: 25) {
                VStack(spacing: 10) {
                    Text("AI-Powered")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.cyan)
                        .opacity(isVisible ? 1 : 0)

                    Text("Coach Assistant")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                }

                VStack(spacing: 20) {
                    FeatureBadge(icon: "lightbulb.fill", text: "Smart Practice Plans", color: .yellow)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring().delay(0.2), value: isVisible)

                    FeatureBadge(icon: "chart.line.uptrend.xyaxis", text: "Player Performance Analytics", color: .green)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring().delay(0.3), value: isVisible)

                    FeatureBadge(icon: "person.3.sequence.fill", text: "Lineup Optimization", color: .purple)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring().delay(0.4), value: isVisible)
                }

                Text("Get personalized coaching insights powered by advanced AI that learns your team's patterns")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 40)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: isVisible)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation {
                isVisible = true
                brainPulse = true
            }

            // Generate floating data points
            for i in 0..<12 {
                let angle = Double(i) * 30 * .pi / 180
                let radius: CGFloat = 100
                let x = 100 + cos(angle) * radius
                let y = 100 + sin(angle) * radius
                dataPoints.append(DataPoint(position: CGPoint(x: x, y: y), delay: Double(i) * 0.1))
            }
        }
        .onDisappear {
            isVisible = false
            brainPulse = false
        }
    }
}

// MARK: - Instant Communication Page
struct InstantCommunicationPage: View {
    @State private var isVisible = false
    @State private var messageWaves = false
    @State private var phoneRotation = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Communication Animation
            ZStack {
                // Radiating waves
                ForEach(0..<4) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.6), Color.purple.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 100 + CGFloat(index * 40), height: 100 + CGFloat(index * 40))
                        .scaleEffect(messageWaves ? 1.5 : 1.0)
                        .opacity(messageWaves ? 0 : 0.8)
                        .animation(
                            Animation.easeOut(duration: 2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                            value: messageWaves
                        )
                }

                // Phone devices
                ZStack {
                    // Parent phones
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 40, height: 70)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.purple, lineWidth: 1)
                            )
                            .rotationEffect(.degrees(Double(index - 1) * 30))
                            .offset(x: CGFloat(index - 1) * 60, y: index == 1 ? -20 : 20)
                            .scaleEffect(isVisible ? 1 : 0.5)
                            .opacity(isVisible ? 1 : 0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(index) * 0.1),
                                value: isVisible
                            )
                    }

                    // Center notification bell
                    ZStack {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 80, height: 80)

                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(phoneRotation ? -10 : 10))
                            .animation(
                                Animation.easeInOut(duration: 0.5)
                                    .repeatForever(autoreverses: true),
                                value: phoneRotation
                            )
                    }
                    .shadow(color: Color.purple.opacity(0.6), radius: 20)
                }
            }
            .frame(width: 250, height: 200)

            VStack(spacing: 25) {
                Text("Instant Parent")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.purple)
                    .opacity(isVisible ? 1 : 0)

                Text("Communication")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)

                VStack(spacing: 15) {
                    CommunicationFeature(icon: "bell.fill", text: "Push Notifications")
                    CommunicationFeature(icon: "clock.fill", text: "Schedule Changes")
                    CommunicationFeature(icon: "exclamationmark.triangle.fill", text: "Emergency Alerts")
                }
                .opacity(isVisible ? 1 : 0)
                .animation(.spring().delay(0.3), value: isVisible)

                Text("Reach all parents instantly with push notifications. No more missed messages or forgotten updates.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 40)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
            }
            .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation {
                isVisible = true
                messageWaves = true
                phoneRotation = true
            }
        }
        .onDisappear {
            isVisible = false
            messageWaves = false
            phoneRotation = false
        }
    }
}

// MARK: - Smart Scheduling Page
struct SmartSchedulingPage: View {
    @State private var isVisible = false
    @State private var calendarFloat = false
    @State private var conflictDetected = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Calendar Animation
            ZStack {
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green.opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)

                // Calendar grid
                VStack(spacing: 5) {
                    ForEach(0..<4) { row in
                        HStack(spacing: 5) {
                            ForEach(0..<7) { col in
                                let isConflict = row == 1 && col == 3
                                let isScheduled = (row == 2 && col == 1) || (row == 3 && col == 5)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        isConflict ? Color.red.opacity(0.8) :
                                        isScheduled ? Color.green.opacity(0.8) :
                                        Color.white.opacity(0.1)
                                    )
                                    .frame(width: 25, height: 25)
                                    .overlay(
                                        Group {
                                            if isConflict && conflictDetected {
                                                Image(systemName: "exclamationmark")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            } else if isScheduled {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 8, height: 8)
                                            }
                                        }
                                    )
                                    .scaleEffect(isVisible ? 1 : 0)
                                    .animation(
                                        .spring(response: 0.4, dampingFraction: 0.6)
                                        .delay(Double(row * 7 + col) * 0.02),
                                        value: isVisible
                                    )
                            }
                        }
                    }
                }
                .rotationEffect(.degrees(calendarFloat ? -5 : 5))
                .offset(y: calendarFloat ? -10 : 10)
                .animation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true),
                    value: calendarFloat
                )

                // Clock overlay
                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(x: 60, y: -60)
                    .scaleEffect(isVisible ? 1 : 0)
                    .rotationEffect(.degrees(isVisible ? 0 : -90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: isVisible)
            }
            .frame(width: 250, height: 200)

            VStack(spacing: 25) {
                Text("Smart")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.green)
                    .opacity(isVisible ? 1 : 0)

                Text("Scheduling")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)

                VStack(spacing: 15) {
                    ScheduleFeature(icon: "calendar.badge.plus", text: "Easy Event Creation", color: .blue)
                    ScheduleFeature(icon: "exclamationmark.triangle", text: "Conflict Detection", color: .red)
                    ScheduleFeature(icon: "arrow.triangle.2.circlepath", text: "Automatic Updates", color: .green)
                }
                .opacity(isVisible ? 1 : 0)
                .animation(.spring().delay(0.3), value: isVisible)

                Text("Schedule practices, games, and tournaments with intelligent conflict detection and auto-sync.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 40)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
            }
            .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation {
                isVisible = true
                calendarFloat = true
            }
            withAnimation(.easeInOut(duration: 0.5).delay(1).repeatForever(autoreverses: true)) {
                conflictDetected = true
            }
        }
        .onDisappear {
            isVisible = false
            calendarFloat = false
            conflictDetected = false
        }
    }
}

// MARK: - Roster Management Page
struct RosterManagementPage: View {
    @State private var isVisible = false
    @State private var playerRotation = false
    @State private var statsAnimation = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Roster Animation
            ZStack {
                // Player cards
                ForEach(0..<5) { index in
                    PlayerCard(index: index, isVisible: isVisible)
                        .rotationEffect(.degrees(Double(index - 2) * 15))
                        .offset(x: CGFloat(index - 2) * 10)
                        .scaleEffect(isVisible ? 1 : 0.5)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.1),
                            value: isVisible
                        )
                }

                // Stats overlay
                if statsAnimation {
                    VStack(spacing: 5) {
                        ForEach(0..<3) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange.opacity(0.8))
                                .frame(width: CGFloat.random(in: 40...80), height: 4)
                        }
                    }
                    .offset(x: 60, y: -40)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: 250, height: 200)

            VStack(spacing: 25) {
                Text("Roster")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.orange)
                    .opacity(isVisible ? 1 : 0)

                Text("Management")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)

                VStack(spacing: 15) {
                    RosterFeature(icon: "person.badge.plus", text: "Player Profiles")
                    RosterFeature(icon: "chart.line.uptrend.xyaxis", text: "Development Tracking")
                    RosterFeature(icon: "sportscourt", text: "Position Management")
                }
                .opacity(isVisible ? 1 : 0)
                .animation(.spring().delay(0.3), value: isVisible)

                Text("Track your team roster with detailed player profiles and development analytics.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 40)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
            }
            .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation {
                isVisible = true
                playerRotation = true
            }
            withAnimation(.easeInOut(duration: 1).delay(0.8).repeatForever(autoreverses: true)) {
                statsAnimation = true
            }
        }
        .onDisappear {
            isVisible = false
            playerRotation = false
            statsAnimation = false
        }
    }
}

// MARK: - Real-Time Sync Page
struct RealTimeSyncPage: View {
    @State private var isVisible = false
    @State private var syncRotation = false
    @State private var dataFlow = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Sync Animation
            ZStack {
                // Sync arrows
                ForEach(0..<3) { index in
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(syncRotation ? 360 : 0))
                        .scaleEffect(1 - CGFloat(index) * 0.2)
                        .opacity(0.8 - Double(index) * 0.2)
                        .animation(
                            Animation.linear(duration: 3)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                            value: syncRotation
                        )
                }

                // Data flow particles
                if dataFlow {
                    ForEach(0..<8) { index in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                            .offset(x: 0, y: -80)
                            .rotationEffect(.degrees(Double(index) * 45))
                            .scaleEffect(dataFlow ? 0 : 1)
                            .opacity(dataFlow ? 0 : 1)
                            .animation(
                                Animation.easeOut(duration: 2)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.2),
                                value: dataFlow
                            )
                    }
                }

                // Center icon
                Image(systemName: "iphone.and.arrow.forward")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .scaleEffect(isVisible ? 1 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isVisible)
            }
            .frame(width: 250, height: 200)

            VStack(spacing: 25) {
                Text("Real-Time")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(isVisible ? 1 : 0)

                Text("Parent App Sync")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)

                VStack(spacing: 15) {
                    SyncFeature(icon: "arrow.clockwise", text: "Instant Updates")
                    SyncFeature(icon: "wifi", text: "Live Synchronization")
                    SyncFeature(icon: "checkmark.shield", text: "Secure Data Transfer")
                }
                .opacity(isVisible ? 1 : 0)
                .animation(.spring().delay(0.3), value: isVisible)

                Text("Every change syncs instantly to the Express United parent app. Parents stay informed in real-time.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 40)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
            }
            .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation {
                isVisible = true
                syncRotation = true
                dataFlow = true
            }
        }
        .onDisappear {
            isVisible = false
            syncRotation = false
            dataFlow = false
        }
    }
}

// MARK: - Get Started Page
struct GetStartedPage: View {
    let onGetStarted: () -> Void
    @State private var isAnimating = false
    @State private var buttonPulse = false
    @State private var confetti = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Success Animation
            ZStack {
                // Celebration circles
                ForEach(0..<5) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("BasketballOrange").opacity(0.3 - Double(index) * 0.05),
                                    Color.orange.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120 + CGFloat(index * 30), height: 120 + CGFloat(index * 30))
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 0 : 0.8)
                        .animation(
                            Animation.easeOut(duration: 2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }

                // Checkmark with glow
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.green.opacity(0.6), radius: 20)

                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }

                // Confetti particles
                if confetti {
                    ForEach(0..<12) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                [Color.orange, Color.purple, Color.blue, Color.green].randomElement()!
                            )
                            .frame(width: 10, height: 20)
                            .offset(
                                x: CGFloat.random(in: -100...100),
                                y: confetti ? 200 : -100
                            )
                            .rotationEffect(.degrees(Double.random(in: 0...360)))
                            .opacity(confetti ? 0 : 1)
                            .animation(
                                Animation.easeOut(duration: 2)
                                    .delay(Double(index) * 0.05),
                                value: confetti
                            )
                    }
                }
            }
            .frame(height: 200)

            VStack(spacing: 25) {
                Text("You're All Set!")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(isAnimating ? 1 : 0.8)
                    .opacity(isAnimating ? 1 : 0)

                Text("Experience the power of Express Coach with our interactive demo")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 40)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)

                VStack(spacing: 10) {
                    Label("Sample team data loaded", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("AI Assistant ready", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("Parent sync enabled", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .font(.callout)
                .opacity(isAnimating ? 1 : 0)
                .animation(.spring().delay(0.4), value: isAnimating)
            }

            Spacer()

            // Enhanced Start Button
            Button(action: onGetStarted) {
                ZStack {
                    // Button glow
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color("BasketballOrange").opacity(0.3))
                        .frame(height: 70)
                        .blur(radius: buttonPulse ? 20 : 10)
                        .scaleEffect(buttonPulse ? 1.1 : 1.0)

                    // Button background
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("BasketballOrange"),
                                    Color("BasketballOrange").opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 70)

                    HStack(spacing: 15) {
                        Text("Start Demo")
                            .font(.title2)
                            .fontWeight(.bold)

                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 30)
            .scaleEffect(buttonPulse ? 1.05 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: buttonPulse
            )
            .shadow(color: Color("BasketballOrange").opacity(0.5), radius: 15, x: 0, y: 5)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring()) {
                isAnimating = true
                buttonPulse = true
            }
            withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false)) {
                confetti = true
            }
        }
    }
}

// MARK: - Supporting Views

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black,
                Color("BasketballOrange").opacity(0.15),
                Color.black,
                Color.purple.opacity(0.1),
                Color.black
            ]),
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct ParticleEffectView: View {
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var opacity: Double
        var scale: CGFloat
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color("BasketballOrange").opacity(particle.opacity))
                        .frame(width: 4, height: 4)
                        .scaleEffect(particle.scale)
                        .position(particle.position)
                }
            }
            .onAppear {
                for _ in 0..<20 {
                    let particle = Particle(
                        position: CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        ),
                        opacity: Double.random(in: 0.1...0.3),
                        scale: CGFloat.random(in: 0.5...1.5)
                    )
                    particles.append(particle)
                }

                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    withAnimation(.linear(duration: 3)) {
                        for i in particles.indices {
                            particles[i].position.y -= 2
                            if particles[i].position.y < -20 {
                                particles[i].position.y = geometry.size.height + 20
                                particles[i].position.x = CGFloat.random(in: 0...geometry.size.width)
                            }
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct EnhancedPageIndicator: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalPages, id: \.self) { page in
                ZStack {
                    if page == currentPage {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("BasketballOrange"))
                            .frame(width: 30, height: 8)
                    } else if page < currentPage {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.vertical, 10)
    }
}

struct NextButton: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("BasketballOrange"),
                                Color("BasketballOrange").opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 60)
                    .shadow(color: Color("BasketballOrange").opacity(0.3), radius: 10, x: 0, y: 5)

                HStack(spacing: 10) {
                    Text("Next")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Image(systemName: "arrow.right")
                        .font(.title3)
                        .offset(x: isPressed ? 5 : 0)
                }
                .foregroundColor(.white)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Feature Badge Views

struct FeatureBadge: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30, height: 30)

            Text(text)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 40)
    }
}

struct CommunicationFeature: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.purple)

            Text(text)
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct ScheduleFeature: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)

            Text(text)
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct RosterFeature: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.orange)

            Text(text)
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct SyncFeature: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text(text)
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct PlayerCard: View {
    let index: Int
    let isVisible: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(
                LinearGradient(
                    colors: [
                        Color("BasketballOrange").opacity(0.3),
                        Color("BasketballOrange").opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 60, height: 90)
            .overlay(
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text("#\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 40, height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 30, height: 4)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("BasketballOrange").opacity(0.5), lineWidth: 1)
            )
    }
}

#Preview {
    OnboardingView(onComplete: {
        print("Onboarding completed")
    })
}