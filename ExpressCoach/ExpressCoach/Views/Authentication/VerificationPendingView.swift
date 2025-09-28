import SwiftUI

struct VerificationPendingView: View {
    let email: String
    @Environment(\.dismiss) var dismiss
    @State private var animateIcon = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.15, blue: 0.4),
                    Color(red: 0.15, green: 0.1, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                VStack(spacing: 32) {
                    // Animated email icon
                    ZStack {
                        // Pulse circles
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(Color("BasketballOrange").opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                                .frame(width: 120 + CGFloat(index * 30), height: 120 + CGFloat(index * 30))
                                .scaleEffect(pulseAnimation ? 1.1 : 0.9)
                                .opacity(pulseAnimation ? 0 : 0.6)
                                .animation(
                                    Animation.easeOut(duration: 2)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(index) * 0.3),
                                    value: pulseAnimation
                                )
                        }
                        
                        // Main icon container
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color("BasketballOrange"),
                                        Color("BasketballOrange").opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: Color("BasketballOrange").opacity(0.5), radius: 20)
                        
                        // Email icon
                        Image(systemName: "envelope.open.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(animateIcon ? -5 : 5))
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: animateIcon
                            )
                    }
                    
                    VStack(spacing: 16) {
                        Text("Check your email")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("We've sent a magic link to")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(email)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("BasketballOrange"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color("BasketballOrange").opacity(0.15))
                            .cornerRadius(20)
                    }
                    .multilineTextAlignment(.center)
                    
                    VStack(spacing: 20) {
                        // Info cards
                        InfoCard(
                            icon: "clock.fill",
                            title: "Link expires in 1 hour",
                            color: .blue
                        )
                        
                        InfoCard(
                            icon: "shield.lefthalf.filled",
                            title: "One-time use only",
                            color: .green
                        )
                        
                        InfoCard(
                            icon: "folder.fill",
                            title: "Check spam folder if needed",
                            color: .orange
                        )
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Bottom actions
                VStack(spacing: 16) {
                    Button(action: openEmailApp) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.white)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 18))
                                Text("Open Email App")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.black)
                        }
                        .frame(height: 56)
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: { dismiss() }) {
                        Text("Try another method")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            animateIcon = true
            pulseAnimation = true
        }
    }
    
    private func openEmailApp() {
        if let url = URL(string: "message://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    VerificationPendingView(email: "coach@example.com")
}