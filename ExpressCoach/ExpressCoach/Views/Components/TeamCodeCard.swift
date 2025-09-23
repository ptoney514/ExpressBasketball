//
//  TeamCodeCard.swift
//  ExpressCoach
//
//  Displays and shares team code for parent app access
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct TeamCodeCard: View {
    let team: Team
    @State private var showingShareSheet = false
    @State private var showingQRCode = false
    @State private var copiedToClipboard = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .foregroundColor(Color("BasketballOrange"))
                    Text("Team Code")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Spacer()

                // QR Code button
                Button(action: { showingQRCode = true }) {
                    Image(systemName: "qrcode")
                        .foregroundColor(Color("BasketballOrange"))
                        .font(.title3)
                }
            }

            // Team Code Display
            VStack(spacing: 12) {
                Text("Share this code with parents to join your team")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                // Code display with copy functionality
                HStack(spacing: 4) {
                    ForEach(Array(team.teamCode), id: \.self) { character in
                        Text(String(character))
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("BasketballOrange").opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("BasketballOrange").opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .onTapGesture {
                    copyToClipboard()
                }

                // Action buttons
                HStack(spacing: 12) {
                    // Copy button
                    Button(action: copyToClipboard) {
                        Label(copiedToClipboard ? "Copied!" : "Copy Code",
                              systemImage: copiedToClipboard ? "checkmark.circle.fill" : "doc.on.doc")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(copiedToClipboard ? Color.green : Color("BasketballOrange"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(copiedToClipboard ? Color.green.opacity(0.2) : Color("BasketballOrange").opacity(0.2))
                            )
                    }

                    // Share button
                    Button(action: { showingShareSheet = true }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("BasketballOrange"))
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color("BackgroundDark"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("BasketballOrange").opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generateShareMessage()])
        }
        .sheet(isPresented: $showingQRCode) {
            QRCodeView(team: team)
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
}

// QR Code View
struct QRCodeView: View {
    let team: Team
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(team.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Team Code: \(team.teamCode)")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                // QR Code
                if let qrImage = generateQRCode(from: team.teamCode) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 250, height: 250)
                        .overlay(
                            Text("QR Code Generation Failed")
                                .foregroundColor(.gray)
                        )
                }

                Text("Parents can scan this code\nto join the team instantly")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
            .navigationTitle("Team QR Code")
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

// Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Preview
#Preview {
    let sampleTeam = Team(
        name: "Express Lightning",
        ageGroup: "U14",
        coachName: "Coach Johnson",
        coachRole: .headCoach
    )

    return TeamCodeCard(team: sampleTeam)
        .padding()
        .background(Color.black)
}