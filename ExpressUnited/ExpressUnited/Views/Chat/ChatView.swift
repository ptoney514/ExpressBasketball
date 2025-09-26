//
//  ChatView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct ChatView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "message.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)

                Text("Team Chat")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Chat")
        }
    }
}

#Preview {
    ChatView()
}