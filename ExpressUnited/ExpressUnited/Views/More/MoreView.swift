//
//  MoreView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: RosterListView()) {
                        HStack {
                            Image(systemName: "person.3")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Team Roster")
                        }
                    }

                    NavigationLink(destination: AnnouncementsListView()) {
                        HStack {
                            Image(systemName: "megaphone")
                                .foregroundColor(.orange)
                                .frame(width: 30)
                            Text("Announcements")
                        }
                    }
                }

                Section {
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gear")
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            Text("Settings")
                        }
                    }

                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("Help & Support")
                    }

                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                            .frame(width: 30)
                        Text("About")
                    }
                }
            }
            .navigationTitle("More")
        }
    }
}

#Preview {
    MoreView()
}