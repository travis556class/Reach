//
//  DashboardView.swift
//  Reach
//
//  Created by Paradis d'Abbadon on 19.09.25.
//

import Foundation
import SwiftUI
import Charts

/// Dashboard view showing outreach statistics and user information
struct DashboardView: View {
    // MARK: - Properties
    
    @StateObject private var authManager = AuthenticationManager()
    @State private var showingAuthView = false
    
    // Sample outreach data to verify chart functionality
    let data: [VisitStat] = [
        .init(label: "Visited", value: 25),
        .init(label: "No Answer", value: 10),
        .init(label: "Follow Ups", value: 5)
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // User info header (only shown when authenticated)
                if authManager.isAuthenticated {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                
                                Text(authManager.currentUser?.username ?? "User")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Team")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(authManager.currentUser?.teamID ?? "")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                    }
                } else {
                    // Login prompt (only shown when not authenticated)
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Dashboard")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("View your outreach data and analytics")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingAuthView = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.badge.key")
                                    Text("Login")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.blue)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
                
                // Chart section (always shown)
                VStack(spacing: 12) {
            Text("Outreach Summary")
                .font(.headline)
            
            Chart(data) {
                BarMark(
                    x: .value("Count", $0.value),
                    y: .value("Category", $0.label)
                )
            }
            .frame(height: 200)
        }
        .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showingAuthView) {
                AuthenticationView(
                    isPresented: $showingAuthView,
                    authManager: authManager
                )
            }
        }
    }
}

// MARK: - Supporting Types

/// Model representing a visit statistic for the dashboard
struct VisitStat: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
}
