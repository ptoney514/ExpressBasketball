//
//  PlayerRow.swift
//  ExpressCoach
//
//  Created on 9/19/25.
//

import SwiftUI
import SwiftData

struct PlayerRow: View {
    let player: Player
    var showContactInfo: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Jersey number circle
            ZStack {
                Circle()
                    .fill(Color("BasketballOrange"))
                    .frame(width: 40, height: 40)

                Text(player.jerseyNumber)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }

            // Player info
            VStack(alignment: .leading, spacing: 2) {
                Text(player.fullName)
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(player.position)
                        .font(.caption)
                        .foregroundColor(Color("BasketballOrange"))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color("CoachBlack"))
                        .cornerRadius(4)

                    Text("Class of \(String(player.graduationYear))")
                        .font(.caption)
                        .foregroundColor(.gray)

                    if let height = player.height, !height.isEmpty {
                        Text(height)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                if showContactInfo {
                    VStack(alignment: .leading, spacing: 1) {
                        ContactRow(icon: "person.fill", text: player.parentName ?? "Not provided", color: .white)
                        ContactRow(icon: "envelope.fill", text: player.parentEmail ?? "Not provided", color: Color("CourtGreen"))
                        ContactRow(icon: "phone.fill", text: player.parentPhone ?? "Not provided", color: Color("BasketballOrange"))
                    }
                    .padding(.top, 4)
                }
            }

            Spacer()

            // Status indicator
            if player.isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("CourtGreen"))
                    .font(.title3)
            } else {
                Image(systemName: "pause.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color("BackgroundDark"))
        .cornerRadius(8)
        .onTapGesture {
            onTap?()
        }
    }
}

struct ContactRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
                .frame(width: 12)

            Text(text)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

struct PlayerRow_Compact: View {
    let player: Player
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Jersey number
            ZStack {
                Circle()
                    .fill(isSelected ? Color("BasketballOrange") : Color("CoachBlack"))
                    .frame(width: 32, height: 32)

                Text(player.jerseyNumber)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .black : Color("BasketballOrange"))
            }

            // Name and position
            VStack(alignment: .leading, spacing: 1) {
                Text(player.fullName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Text(player.position)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("BasketballOrange"))
                    .font(.title3)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color("CoachBlack").opacity(0.5) : Color.clear)
        .cornerRadius(6)
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    let samplePlayer = Player(
        firstName: "Michael",
        lastName: "Jordan",
        jerseyNumber: "23",
        position: "Guard",
        graduationYear: 2029,
        parentName: "James Jordan",
        parentEmail: "james.jordan@email.com",
        parentPhone: "(555) 123-4567",
        emergencyContact: "Deloris Jordan",
        emergencyPhone: "(555) 987-6543"
    )
    samplePlayer.height = "6'2\""

    return VStack(spacing: 8) {
        PlayerRow(player: samplePlayer, showContactInfo: false)
        PlayerRow(player: samplePlayer, showContactInfo: true)
        PlayerRow_Compact(player: samplePlayer, isSelected: false)
        PlayerRow_Compact(player: samplePlayer, isSelected: true)
    }
    .preferredColorScheme(.dark)
    .padding()
}