//
//  TeamCodeDetailView.swift
//  ExpressCoach
//
//  Full-screen view for team code display and sharing
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct TeamCodeDetailView: View {
    let team: Team
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var copiedToClipboard = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color("BackgroundDark")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Team Info
                        VStack(spacing: 8) {
                            Text(team.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text(team.ageGroup)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)

                        // QR Code
                        VStack(spacing: 20) {
                            if let qrImage = generateQRCode(from: team.teamCode) {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .padding(20)
                                    .background(Color.white)
                                    .cornerRadius(16)
                            }

                            Text("Parents can scan this QR code")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        // Team Code Display
                        VStack(spacing: 16) {
                            Text("Or enter this code manually")
                                .font(.caption)
                                .foregroundColor(.gray)

                            HStack(spacing: 8) {
                                ForEach(Array(team.teamCode), id: \.self) { character in
                                    Text(String(character))
                                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                        .frame(width: 45, height: 55)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color("BasketballOrange").opacity(0.2))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color("BasketballOrange").opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                            .onTapGesture {
                                copyToClipboard()
                            }
                        }

                        // Action Buttons
                        VStack(spacing: 12) {
                            // Copy button
                            Button(action: copyToClipboard) {
                                Label(copiedToClipboard ? "Copied!" : "Copy Code",
                                      systemImage: copiedToClipboard ? "checkmark.circle.fill" : "doc.on.doc")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(copiedToClipboard ? .white : .black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(copiedToClipboard ? Color.green : Color("BasketballOrange").opacity(0.2))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(copiedToClipboard ? Color.green : Color("BasketballOrange"), lineWidth: 1)
                                    )
                            }

                            // Share button
                            Button(action: { showingShareSheet = true }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("BasketballOrange"))
                                    )
                            }
                        }
                        .padding(.horizontal, 32)

                        // Instructions
                        VStack(spacing: 12) {
                            Text("How Parents Join")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 8) {
                                instructionRow(number: "1", text: "Download Express United app")
                                instructionRow(number: "2", text: "Open the app and tap 'Join Team'")
                                instructionRow(number: "3", text: "Scan QR code or enter the 6-digit code")
                                instructionRow(number: "4", text: "Start receiving team updates!")
                            }
                            .padding()
                            .background(Color("CoachBlack"))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Team Code")
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
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generateShareMessage()])
        }
    }

    private func instructionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color("BasketballOrange")))

            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()
        }
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = team.teamCode

        withAnimation(.easeInOut(duration: 0.2)) {
            copiedToClipboard = true
        }

        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copiedToClipboard = false
            }
        }
    }

    private func generateShareMessage() -> String {
        """
        Join our team on Express Basketball!

        Team: \(team.name)
        Age Group: \(team.ageGroup)
        Team Code: \(team.teamCode)

        Download the Express United app and enter this code to stay updated with schedules, announcements, and more!
        """
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)

            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return nil
    }
}

// Preview
#Preview {
    TeamCodeDetailView(team: {
        let team = Team(
            name: "Express Lightning",
            teamCode: "LIGHT01",
            organization: "Express Basketball",
            ageGroup: "U14",
            season: "2024-25"
        )
        team.coachName = "Coach Johnson"
        return team
    }())
}