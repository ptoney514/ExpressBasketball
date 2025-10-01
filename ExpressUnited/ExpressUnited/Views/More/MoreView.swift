//
//  MoreView.swift
//  ExpressUnited
//
//  Created for Express Basketball
//

import SwiftUI

struct MoreView: View {
    @State private var showingAppTour = false

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

                    Button(action: { showingAppTour = true }) {
                        HStack {
                            Image(systemName: "hand.wave.fill")
                                .foregroundColor(.orange)
                                .frame(width: 30)
                            Text("App Tour")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .foregroundColor(.primary)

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
            .fullScreenCover(isPresented: $showingAppTour) {
                AppTourView()
            }
        }
    }
}

#Preview {
    MoreView()
}