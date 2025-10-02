//
//  AppTourView.swift
//  ExpressUnited
//
//  Modern onboarding tour showcasing app benefits for parents and players
//

import SwiftUI

struct AppTourView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var isAnimating = false

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "bell.badge.fill",
            iconColor: .orange,
            title: "Stay Connected",
            description: "Get instant notifications about game schedules, practice changes, and important team announcements—all in one place.",
            animation: .pulse
        ),
        OnboardingPage(
            icon: "calendar.badge.clock",
            iconColor: .blue,
            title: "Never Miss a Game",
            description: "View upcoming games, practices, and tournaments. Get reminders so your player is always prepared and on time.",
            animation: .slide
        ),
        OnboardingPage(
            icon: "message.badge.fill",
            iconColor: .green,
            title: "Important Updates",
            description: "Receive messages from coaches about uniform distribution, weather delays, and last-minute changes—delivered instantly.",
            animation: .fade
        ),
        OnboardingPage(
            icon: "person.3.fill",
            iconColor: .purple,
            title: "Team at Your Fingertips",
            description: "Access your team roster, player stats, and contact information whenever you need it.",
            animation: .scale
        ),
        OnboardingPage(
            icon: "sportscourt.fill",
            iconColor: .orange,
            title: "Built for Youth Basketball",
            description: "Designed specifically for parents and players to follow team activities without the complexity of coaching tools.",
            animation: .rotate
        )
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color(white: 0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray, Color(white: 0.15))
                    }
                    .padding()
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isActive: currentPage == index,
                            pageIndex: index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                // Bottom action buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        Button(action: { dismiss() }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage = pages.count - 1
                            }
                        }) {
                            Text("Skip Tour")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .frame(height: 100)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let animation: AnimationType

    enum AnimationType {
        case pulse, slide, fade, scale, rotate
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    let pageIndex: Int

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Icon with animation
            ZStack {
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                page.iconColor.opacity(0.3),
                                page.iconColor.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 60,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 0.6 : 0.3)

                // Icon background circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                page.iconColor.opacity(0.2),
                                page.iconColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)

                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(page.iconColor)
                    .rotationEffect(.degrees(isAnimating && page.animation == .rotate ? 360 : 0))
                    .scaleEffect(isAnimating && page.animation == .scale ? 1.1 : 1.0)
                    .offset(y: isAnimating && page.animation == .pulse ? -10 : 0)
            }
            .animation(
                isActive ? .easeInOut(duration: 2.0).repeatForever(autoreverses: true) : .default,
                value: isAnimating
            )

            Spacer()

            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(isActive ? 1.0 : 0.5)
                    .scaleEffect(isActive ? 1.0 : 0.9)

                Text(page.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(isActive ? 1.0 : 0.5)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isActive)

            Spacer()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                isAnimating = true
            }
        }
        .onAppear {
            if isActive {
                isAnimating = true
            }
        }
    }
}

// Alternative: Feature-focused onboarding with interactive cards
struct FeatureCardTourView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Welcome to Express United")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray, Color(white: 0.15))
                    }
                }
                .padding()

                ScrollView {
                    VStack(spacing: 24) {
                        // Benefit cards
                        BenefitCard(
                            icon: "bell.badge.fill",
                            iconColor: .orange,
                            title: "Instant Notifications",
                            description: "Never miss important updates about games, practices, or schedule changes",
                            benefits: [
                                "Free push notifications",
                                "Real-time updates",
                                "No email required"
                            ]
                        )

                        BenefitCard(
                            icon: "calendar.badge.clock",
                            iconColor: .blue,
                            title: "Smart Schedule",
                            description: "See all games, practices, and tournaments at a glance",
                            benefits: [
                                "Upcoming events",
                                "Location & directions",
                                "Auto reminders"
                            ]
                        )

                        BenefitCard(
                            icon: "message.fill",
                            iconColor: .green,
                            title: "Direct Messages",
                            description: "Get coach updates straight to your phone",
                            benefits: [
                                "Team announcements",
                                "Urgent alerts",
                                "Important documents"
                            ]
                        )

                        BenefitCard(
                            icon: "lock.shield.fill",
                            iconColor: .purple,
                            title: "Safe & Private",
                            description: "COPPA compliant with no personal data collection",
                            benefits: [
                                "No email signup",
                                "Secure team codes",
                                "Privacy first"
                            ]
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }

                // Get Started button (fixed at bottom)
                VStack {
                    Button(action: { dismiss() }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 150)
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct BenefitCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let benefits: [String]

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(iconColor)
                }

                // Title and description
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                Spacer()
            }

            // Benefits list
            VStack(alignment: .leading, spacing: 8) {
                ForEach(benefits, id: \.self) { benefit in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(iconColor)

                        Text(benefit)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(16)
    }
}

#Preview("Animated Tour") {
    AppTourView()
}

#Preview("Feature Cards") {
    FeatureCardTourView()
}
