//
//  TeamView.swift
//  Reach
//
//

import Foundation
import SwiftUI

/// Team management view with authentication
struct TeamView: View {
    // MARK: - Properties
    
    @ObservedObject var authManager: AuthenticationManager
    @State private var showingAuthView = false
    @State private var showingLogoutConfirmation = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            if authManager.isAuthenticated {
                authenticatedView
            } else {
                unauthenticatedView
            }
        }
    }
    
    // MARK: - Authenticated View
    
    private var authenticatedView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                profileHeader
                
                // Team Info Card
                teamInfoCard
                
                // Quick Actions
                quickActions
                
                Spacer(minLength: 40)
                
                // Logout Button
                logoutButton
            }
            .padding()
        }
        .navigationTitle("Team")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            "Sign Out",
            isPresented: $showingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                authManager.logout()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 100, height: 100)
                
                Text(String(authManager.currentUser?.username.prefix(2).uppercased() ?? "US"))
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // User Info
            VStack(spacing: 4) {
                Text(authManager.currentUser?.username ?? "User")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    Image(systemName: "person.3.fill")
                        .font(.caption)
                    Text("Team \(authManager.currentUser?.teamID ?? "")")
                        .font(.subheadline)
                }
                .foregroundStyle(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    Capsule()
                        .fill(.blue.opacity(0.1))
                }
            }
            
            // Member Since
            if let loginDate = authManager.currentUser?.loginDate {
                Text("Member since \(loginDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private var teamInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Team Information", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundStyle(.blue)
            
            VStack(spacing: 12) {
                InfoRow(icon: "person.badge.key", label: "Account Type", value: "Team Member")
                Divider()
                InfoRow(icon: "checkmark.shield.fill", label: "Status", value: "Active")
                Divider()
                InfoRow(icon: "calendar", label: "Joined", value: authManager.currentUser?.loginDate.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Quick Actions", systemImage: "bolt.fill")
                .font(.headline)
                .foregroundStyle(.blue)
            
            VStack(spacing: 12) {
                ActionButton(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Sync Data",
                    subtitle: "Update with team database"
                ) {
                    // Sync action
                }
                
                ActionButton(
                    icon: "chart.bar.doc.horizontal",
                    title: "View Team Stats",
                    subtitle: "See collective progress"
                ) {
                    // Stats action
                }
                
                ActionButton(
                    icon: "person.2.fill",
                    title: "Team Members",
                    subtitle: "View active members"
                ) {
                    // Members action
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private var logoutButton: some View {
        Button {
            showingLogoutConfirmation = true
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(.red)
    }
    
    // MARK: - Unauthenticated View
    
    private var unauthenticatedView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue.gradient)
                        .symbolEffect(.pulse)
                }
                
                // Text Content
                VStack(spacing: 12) {
                    Text("Join Your Team")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to collaborate with your outreach team, sync data, and track collective progress")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Features List
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "arrow.triangle.2.circlepath.circle.fill", title: "Real-time Sync", description: "Keep data updated across devices")
                    FeatureRow(icon: "chart.bar.fill", title: "Team Analytics", description: "View collective performance")
                    FeatureRow(icon: "person.3.fill", title: "Collaboration", description: "Work together efficiently")
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.regularMaterial)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Sign In Button
            Button {
                showingAuthView = true
            } label: {
                HStack {
                    Image(systemName: "person.badge.key.fill")
                    Text("Sign In")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Team")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAuthView) {
            AuthenticationView(
                isPresented: $showingAuthView,
                authManager: authManager
            )
        }
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 36)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            }
        }
        .buttonStyle(.plain)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue.gradient)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview("Authenticated") {
    let authManager = AuthenticationManager()
    authManager.login(username: "johndoe", password: "password", teamID: "TEAM001")
    return TeamView(authManager: authManager)
}

#Preview("Unauthenticated") {
    TeamView(authManager: AuthenticationManager())
}
