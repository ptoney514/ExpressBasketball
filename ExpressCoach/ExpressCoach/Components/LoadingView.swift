//
//  LoadingView.swift
//  ExpressCoach
//
//  Reusable loading indicator component
//

import SwiftUI

struct LoadingView: View {
    let message: String?
    var style: LoadingStyle = .standard

    init(message: String? = nil, style: LoadingStyle = .standard) {
        self.message = message
        self.style = style
    }

    enum LoadingStyle {
        case standard
        case overlay
        case inline
        case fullScreen
    }

    var body: some View {
        switch style {
        case .standard:
            standardView
        case .overlay:
            overlayView
        case .inline:
            inlineView
        case .fullScreen:
            fullScreenView
        }
    }

    private var standardView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.blue)

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message ?? "Loading")
    }

    private var overlayView: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                    .progressViewStyle(CircularProgressViewStyle())

                if let message = message {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(24)
            .background(Color.black.opacity(0.7))
            .cornerRadius(AppConstants.UI.cornerRadius)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message ?? "Loading")
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var inlineView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)

            if let message = message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message ?? "Loading")
    }

    private var fullScreenView: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(2)
                    .tint(.blue)

                if let message = message {
                    Text(message)
                        .font(.title3)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message ?? "Loading")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

struct LoadingOverlay: ViewModifier {
    let isLoading: Bool
    let message: String?

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)

            if isLoading {
                LoadingView(message: message, style: .overlay)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: AppConstants.UI.quickAnimationDuration), value: isLoading)
    }
}

extension View {
    func loadingOverlay(isLoading: Bool, message: String? = nil) -> some View {
        modifier(LoadingOverlay(isLoading: isLoading, message: message))
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            LoadingView(message: "Loading roster...", style: .standard)
            LoadingView(message: "Saving...", style: .inline)
            LoadingView(style: .standard)
        }
        .padding()
    }
}