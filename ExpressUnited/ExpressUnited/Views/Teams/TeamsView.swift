//
//  TeamsView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct TeamsView: View {
    var body: some View {
        NavigationView {
            List {
                TeamRow(teamName: "Express United 14U", role: "Parent", color: .orange)
            }
            .navigationTitle("My Teams")
        }
    }
}

struct TeamRow: View {
    let teamName: String
    let role: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(teamName.prefix(2).uppercased()))
                        .font(.headline)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(teamName)
                    .font(.headline)

                Text(role)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    TeamsView()
}