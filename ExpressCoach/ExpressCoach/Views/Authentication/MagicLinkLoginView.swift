import SwiftUI
import Supabase

struct MagicLinkLoginView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingVerification = false
    @State private var errorMessage: String?
    @State private var useTeamCode = false
    @State private var teamCode = ""
    
    // Supabase client - will be properly configured later
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "http://127.0.0.1:54321")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
    )
    
    var body: some View {
        ZStack {
            // Background gradient matching reference design
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.15, blue: 0.4), // Deep purple
                    Color(red: 0.15, green: 0.1, blue: 0.3),  // Darker purple
                    Color(red: 0.25, green: 0.2, blue: 0.5)   // Lighter purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Diagonal pattern overlay
            GeometryReader { geometry in
                Path { path in
                    for i in stride(from: -geometry.size.width, through: geometry.size.width * 2, by: 30) {
                        path.move(to: CGPoint(x: i, y: 0))
                        path.addLine(to: CGPoint(x: i + geometry.size.height, y: geometry.size.height))
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.2), Color.purple.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                // Logo section
                VStack(spacing: 16) {
                    // Logo with border
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: "basketball.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color("BasketballOrange"))
                    }
                    .padding(.top, 40)
                    
                    Text("WELCOME")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    Text("Enter the email you used\nwhen registering for the team")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.bottom, 40)
                
                // Email input section
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        TextField("", text: $email)
                            .placeholder(when: email.isEmpty) {
                                Text("coach@example.com")
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.white.opacity(0.3))
                                    .offset(y: 20)
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }
                }
                
                // Buttons section
                VStack(spacing: 20) {
                    // Magic Link Button
                    Button(action: sendMagicLink) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.white)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Login with a magic link")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(height: 56)
                    }
                    .disabled(email.isEmpty || isLoading)
                    .opacity(email.isEmpty ? 0.6 : 1.0)
                    .padding(.horizontal, 24)
                    
                    Text("Or")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    // Team Code Button
                    Button(action: { useTeamCode.toggle() }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(28)
                            
                            Text("Login with team code")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(height: 56)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    Text("By continuing, you agree to our")
                        .foregroundColor(.white.opacity(0.5))
                    
                    HStack(spacing: 4) {
                        Button(action: {}) {
                            Text("Terms")
                                .foregroundColor(.white.opacity(0.7))
                                .underline()
                        }
                        
                        Text("and")
                            .foregroundColor(.white.opacity(0.5))
                        
                        Button(action: {}) {
                            Text("Privacy Policy")
                                .foregroundColor(.white.opacity(0.7))
                                .underline()
                        }
                    }
                }
                .font(.caption)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showingVerification) {
            VerificationPendingView(email: email)
        }
        .sheet(isPresented: $useTeamCode) {
            TeamCodeEntryView()
        }
    }
    
    private func sendMagicLink() {
        guard !email.isEmpty else { return }
        
        // Validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Send magic link
                try await supabase.auth.signInWithOTP(
                    email: email,
                    redirectTo: URL(string: "expresscoach://login-callback")
                )
                
                await MainActor.run {
                    isLoading = false
                    showingVerification = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to send magic link. Please try again."
                    print("Magic link error: \(error)")
                }
            }
        }
    }
}

// Helper extension for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    MagicLinkLoginView()
}