//
//  TeamView.swift
//  Reach
//
//  Created by Paradis d'Abbadon on 19.09.25.
//

import Foundation
import SwiftUI

/// Team management view with authentication
struct TeamView: View {
    // MARK: - Properties
    
    @StateObject private var authManager = AuthenticationManager()
    @State private var showingAuthView = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            if authManager.isAuthenticated {
                // Authenticated view
                VStack {
                    // Welcome header
                    VStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Welcome, \(authManager.currentUser?.username ?? "User")!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Team ID: \(authManager.currentUser?.teamID ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Team content placeholder
                    VStack(spacing: 20) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Team Dashboard")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Team management features coming soon")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Logout button
                    Button(action: {
                        authManager.logout()
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .navigationTitle("Team")
            } else {
                // Login prompt view
                VStack(spacing: 30) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Team Access Required")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Please log in to access team management features and collaborate with your outreach team.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        showingAuthView = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.key")
                            Text("Login")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .navigationTitle("Team")
                .sheet(isPresented: $showingAuthView) {
                    AuthenticationView(
                        isPresented: $showingAuthView,
                        authManager: authManager
                    )
                }
            }
        }
    }
}

#Preview {
    TeamView()
}

