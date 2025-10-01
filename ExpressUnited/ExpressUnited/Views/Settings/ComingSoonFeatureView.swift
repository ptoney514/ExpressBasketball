//
//  ComingSoonFeatureView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct ComingSoonFeatureView: View {
    @Environment(\.dismiss) private var dismiss
    let feature: ComingSoonFeature

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Image(systemName: feature.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)

                VStack(spacing: 15) {
                    Text(feature.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Coming Soon!")
                        .font(.title2)
                        .foregroundStyle(.orange)
                }

                Text(feature.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if !feature.benefits.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(feature.benefits, id: \.self) { benefit in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title3)

                                Text(benefit)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }

                Spacer()

                VStack(spacing: 15) {
                    Text("We're working hard to bring this feature to you!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Got It")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct ComingSoonFeature {
    let icon: String
    let title: String
    let description: String
    let benefits: [String]

    static let emailNotifications = ComingSoonFeature(
        icon: "envelope.fill",
        title: "Email Notifications",
        description: "Receive team updates and announcements directly in your email inbox as a backup to push notifications.",
        benefits: [
            "Email summaries of daily team updates",
            "Digest mode: Daily or weekly summaries",
            "Perfect for parents who prefer email",
            "Never miss an update even if you're not checking the app"
        ]
    )

    static let smsAlerts = ComingSoonFeature(
        icon: "message.fill",
        title: "SMS Text Alerts",
        description: "Get urgent updates via text message for critical schedule changes and game-day alerts.",
        benefits: [
            "Instant text alerts for game cancellations",
            "Weather-related schedule changes",
            "Emergency notifications",
            "Opt-in only - you control what you receive"
        ]
    )
}

#Preview("Email") {
    ComingSoonFeatureView(feature: .emailNotifications)
}

#Preview("SMS") {
    ComingSoonFeatureView(feature: .smsAlerts)
}
