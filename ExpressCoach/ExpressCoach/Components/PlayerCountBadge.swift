//
//  PlayerCountBadge.swift
//  ExpressCoach
//
//  Reusable player count display component
//

import SwiftUI

struct PlayerCountBadge: View {
    let count: Int
    var style: BadgeStyle = .standard

    enum BadgeStyle {
        case standard
        case compact
        case prominent
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: style == .compact ? 2 : 4) {
            HStack(spacing: 4) {
                Image(systemName: "person.fill")
                    .font(iconFont)
                    .accessibilityHidden(true)
                Text("\(count)")
                    .font(countFont)
                    .bold()
            }
            .foregroundColor(foregroundColor)

            if style != .compact {
                Text("Players")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(count) players")
    }

    private var iconFont: Font {
        switch style {
        case .standard, .compact:
            return .caption
        case .prominent:
            return .body
        }
    }

    private var countFont: Font {
        switch style {
        case .standard:
            return .caption
        case .compact:
            return .caption2
        case .prominent:
            return .title2
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .standard, .compact:
            return .blue
        case .prominent:
            return .primary
        }
    }
}

struct PlayerCountBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PlayerCountBadge(count: 12, style: .standard)
            PlayerCountBadge(count: 8, style: .compact)
            PlayerCountBadge(count: 15, style: .prominent)
        }
        .padding()
    }
}