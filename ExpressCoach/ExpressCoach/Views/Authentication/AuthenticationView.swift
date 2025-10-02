import SwiftUI

struct AuthenticationView: View {
    @State private var selectedTab = 0
    @State private var email = ""
    @State private var isShowingMagicLink = false
    @State private var isShowingEmailPassword = false
    @State private var isShowingTeamCode = false
    
    var body: some View {
        ZStack {
            // Gradient background similar to reference
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundDark"),
                    Color("BasketballOrange").opacity(0.15),
                    Color("BackgroundDark")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Diagonal pattern overlay
            GeometryReader { geometry in
                Path { path in
                    for i in stride(from: -geometry.size.width, through: geometry.size.width * 2, by: 40) {
                        path.move(to: CGPoint(x: i, y: 0))
                        path.addLine(to: CGPoint(x: i + geometry.size.height, y: geometry.size.height))
                    }
                }
                .stroke(Color.purple.opacity(0.1), lineWidth: 2)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Logo and title section
                VStack(spacing: 20) {
                    // Logo placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "basketball.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color("BasketballOrange"))
                    }
                    .padding(.top, 60)
                    
                    Text("WELCOME")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(3)
                    
                    Text("Choose how you'd like to sign in")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
                
                // Authentication options
                VStack(spacing: 16) {
                    // Magic Link Button (Primary)
                    Button(action: {
                        isShowingMagicLink = true
                    }) {
                        HStack {
                            Image(systemName: "envelope.badge.fill")
                                .font(.system(size: 20))
                            Text("Sign in with Magic Link")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                    }
                    
                    // Divider with "Or"
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                        Text("Or")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Email/Password Button
                    Button(action: {
                        isShowingEmailPassword = true
                    }) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                            Text("Sign in with Email & Password")
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(28)
                    }
                    
                    // Social Login Options
                    HStack(spacing: 16) {
                        // Sign in with Apple
                        Button(action: {
                            // Handle Apple Sign In
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.white)
                                    .frame(height: 56)
                                
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 20))
                                        .foregroundColor(.black)
                                    Text("Apple")
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        
                        // Sign in with Google
                        Button(action: {
                            // Handle Google Sign In
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.white)
                                    .frame(height: 56)
                                
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                    Text("Google")
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    
                    // Team Code Entry (Alternative)
                    Button(action: {
                        isShowingTeamCode = true
                    }) {
                        HStack {
                            Image(systemName: "qrcode")
                                .font(.system(size: 20))
                            Text("Enter Team Code")
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(Color("BasketballOrange"))
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("BasketballOrange").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color("BasketballOrange").opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(28)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Footer
                VStack(spacing: 16) {
                    Button(action: {
                        // Handle create account
                    }) {
                        Text("New coach? ")
                            .foregroundColor(.white.opacity(0.6)) +
                        Text("Create an account")
                            .foregroundColor(Color("BasketballOrange"))
                            .fontWeight(.semibold)
                    }
                    .font(.callout)
                    
                    // Terms and Privacy
                    Text("By continuing, you agree to our ")
                        .foregroundColor(.white.opacity(0.4)) +
                    Text("Terms")
                        .foregroundColor(.white.opacity(0.6))
                        .underline() +
                    Text(" and ")
                        .foregroundColor(.white.opacity(0.4)) +
                    Text("Privacy Policy")
                        .foregroundColor(.white.opacity(0.6))
                        .underline()
                }
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $isShowingMagicLink) {
            MagicLinkLoginView()
        }
        .sheet(isPresented: $isShowingEmailPassword) {
            EmailPasswordLoginView()
        }
        .sheet(isPresented: $isShowingTeamCode) {
            TeamCodeEntryView()
        }
    }
}

#Preview {
    AuthenticationView()
}