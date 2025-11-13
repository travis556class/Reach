//
//  DashboardView.swift
//  Reach
//
//  Enhanced following Apple HIG
//

import Foundation
import SwiftUI
import Charts

/// Dashboard view showing outreach statistics and user information
struct DashboardView: View {
    // MARK: - Properties
    
    @ObservedObject var authManager: AuthenticationManager
    let pins: [PinData]
    @State private var showingAuthView = false
    
    // MARK: - Computed Properties
    
    private var stats: DashboardStats {
        let answered = pins.filter { $0.answerStatus == .answered }.count
        let noAnswer = pins.filter { $0.answerStatus == .noAnswer }.count
        let positive = pins.filter { $0.answerStatus == .answered && $0.responseType == .positive }.count
        let negative = pins.filter { $0.answerStatus == .answered && $0.responseType == .negative }.count
        
        return DashboardStats(
            totalVisits: pins.count,
            answered: answered,
            noAnswer: noAnswer,
            positive: positive,
            negative: negative
        )
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // User Profile Card
                    if authManager.isAuthenticated {
                        authenticatedHeader
                    } else {
                        unauthenticatedHeader
                    }
                    
                    // Quick Stats Cards
                    quickStatsGrid
                    
                    // Chart Section
                    if pins.count > 0 {
                        chartSection
                        responseBreakdownChart
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingAuthView) {
                AuthenticationView(
                    isPresented: $showingAuthView,
                    authManager: authManager
                )
            }
        }
    }
    
    // MARK: - View Components
    
    private var authenticatedHeader: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue.gradient)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(authManager.currentUser?.username ?? "User")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .font(.caption)
                    Text("Team \(authManager.currentUser?.teamID ?? "")")
                        .font(.subheadline)
                }
                .foregroundStyle(.blue)
            }
            
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private var unauthenticatedHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sign in to sync")
                        .font(.headline)
                    
                    Text("Access team analytics and cloud sync")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    showingAuthView = true
                } label: {
                    Label("Sign In", systemImage: "person.crop.circle.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private var quickStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Total Visits",
                value: "\(stats.totalVisits)",
                icon: "flag.fill",
                color: .blue
            )
            
            StatCard(
                title: "Answered",
                value: "\(stats.answered)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "No Answer",
                value: "\(stats.noAnswer)",
                icon: "bell.slash.fill",
                color: .orange
            )
            
            StatCard(
                title: "Positive",
                value: "\(stats.positive)",
                icon: "hand.thumbsup.fill",
                color: .mint
            )
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Visit Summary")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                BarMark(
                    x: .value("Count", stats.answered),
                    y: .value("Type", "Answered")
                )
                .foregroundStyle(.green.gradient)
                .annotation(position: .trailing) {
                    Text("\(stats.answered)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                BarMark(
                    x: .value("Count", stats.noAnswer),
                    y: .value("Type", "No Answer")
                )
                .foregroundStyle(.orange.gradient)
                .annotation(position: .trailing) {
                    Text("\(stats.noAnswer)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private var responseBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Response Breakdown")
                .font(.headline)
                .padding(.horizontal)
            
            if stats.answered > 0 {
                Chart {
                    SectorMark(
                        angle: .value("Count", stats.positive),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(.green.gradient)
                    .cornerRadius(4)
                    
                    SectorMark(
                        angle: .value("Count", stats.negative),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(.red.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .padding()
                
                HStack(spacing: 20) {
                    Label("\(stats.positive) Positive", systemImage: "circle.fill")
                        .foregroundStyle(.green)
                        .font(.subheadline)
                    
                    Label("\(stats.negative) Negative", systemImage: "circle.fill")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
                .padding(.horizontal)
                .padding(.bottom)
            } else {
                Text("No responses recorded yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "map.circle")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("No Visits Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start adding pins on the map to track your outreach progress")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color.gradient)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Supporting Types

struct DashboardStats {
    let totalVisits: Int
    let answered: Int
    let noAnswer: Int
    let positive: Int
    let negative: Int
}

// MARK: - Preview
#Preview {
    DashboardView(
        authManager: AuthenticationManager(),
        pins: [
            PinData(coordinate: .school, residenceType: .house, answerStatus: .answered, responseType: .positive),
            PinData(coordinate: .school, residenceType: .apartment, answerStatus: .noAnswer, responseType: .positive)
        ]
    )
}
