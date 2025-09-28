import SwiftUI
import SwiftData

struct TeamCodeEntryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var teams: [Team]
    
    @State private var teamCode = ""
    @State private var digitFields: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var isValidating = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundDark"),
                    Color.purple.opacity(0.2),
                    Color("BackgroundDark")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
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
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Icon and title
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.purple.opacity(0.3),
                                                Color.purple.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "qrcode")
                                    .font(.system(size: 48))
                                    .foregroundColor(.purple)
                            }
                            
                            VStack(spacing: 12) {
                                Text("Enter Team Code")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Join your team using the 6-character code\nprovided by your organization")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Code input fields
                        HStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                CodeDigitField(
                                    text: $digitFields[index],
                                    focusedField: $focusedField,
                                    index: index,
                                    onTextChange: { newValue in
                                        handleTextChange(newValue, at: index)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Error message
                        if let errorMessage = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                Text(errorMessage)
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                        }
                        
                        // Instructions
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                
                                Text("Team codes are case-insensitive")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.green)
                                
                                Text("Ask your coach or director for the code")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        
                        // Validate button
                        Button(action: validateTeamCode) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(
                                        digitFields.allSatisfy({ !$0.isEmpty }) ?
                                        Color("BasketballOrange") :
                                        Color.gray.opacity(0.3)
                                    )
                                
                                if isValidating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Join Team")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(height: 56)
                        }
                        .disabled(!digitFields.allSatisfy({ !$0.isEmpty }) || isValidating)
                        .padding(.horizontal, 24)
                        
                        // Alternative options
                        VStack(spacing: 16) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Scan QR Code")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.purple)
                            }
                            
                            Text("or")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Button(action: startDemoMode) {
                                Text("Try Demo Mode")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("BasketballOrange"))
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            focusedField = 0
        }
        .alert("Team Joined!", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("You've successfully joined the team.")
        }
    }
    
    private func handleTextChange(_ newValue: String, at index: Int) {
        // Handle input
        if newValue.count > 1 {
            // User pasted or typed multiple characters
            let code = newValue.uppercased().filter { $0.isLetter || $0.isNumber }
            let characters = Array(code)
            
            for (i, char) in characters.enumerated() {
                if index + i < 6 {
                    digitFields[index + i] = String(char)
                }
            }
            
            // Move to next empty field or last field
            if let nextEmpty = digitFields.firstIndex(where: { $0.isEmpty }) {
                focusedField = nextEmpty
            } else {
                focusedField = 5
            }
        } else if newValue.count == 1 {
            // Single character typed
            digitFields[index] = newValue.uppercased()
            if index < 5 {
                focusedField = index + 1
            }
        } else {
            // Backspace pressed
            digitFields[index] = ""
            if index > 0 {
                focusedField = index - 1
            }
        }
    }
    
    private func validateTeamCode() {
        let code = digitFields.joined().uppercased()
        guard code.count == 6 else { return }
        
        isValidating = true
        errorMessage = nil
        
        // Check if team with this code exists
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Simulate network delay
            if let team = teams.first(where: { $0.teamCode == code }) {
                showSuccess = true
                isValidating = false
            } else if code == "DEMO01" || code == "TEST01" {
                // Accept demo codes
                startDemoMode()
                isValidating = false
            } else {
                errorMessage = "Invalid team code. Please check and try again."
                isValidating = false
                
                // Clear fields
                digitFields = Array(repeating: "", count: 6)
                focusedField = 0
            }
        }
    }
    
    private func startDemoMode() {
        // Enable demo mode
        DemoDataManager.shared.setDemoMode(true)
        
        // Create demo data if needed
        if teams.isEmpty {
            do {
                try DemoDataManager.shared.seedDemoData(in: modelContext)
            } catch {
                print("Failed to create demo data: \(error)")
            }
        }
        
        dismiss()
    }
}

struct CodeDigitField: View {
    @Binding var text: String
    @FocusState.Binding var focusedField: Int?
    let index: Int
    let onTextChange: (String) -> Void
    
    var body: some View {
        TextField("", text: $text)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(width: 50, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        focusedField == index ? Color("BasketballOrange") : Color.white.opacity(0.2),
                        lineWidth: focusedField == index ? 2 : 1
                    )
            )
            .textInputAutocapitalization(.characters)
            .autocorrectionDisabled()
            .focused($focusedField, equals: index)
            .onChange(of: text) { oldValue, newValue in
                onTextChange(newValue)
            }
    }
}

#Preview {
    TeamCodeEntryView()
        .modelContainer(for: Team.self, inMemory: true)
}