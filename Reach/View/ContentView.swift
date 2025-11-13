//
//  ContentView.swift
//  Reach
//
//  Enhanced following Apple HIG with SwiftData
//

import SwiftUI
import SwiftData

/// Main content view that manages the app's tab navigation
struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var locationManager = LocationManager()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PinData.timestamp, order: .reverse) private var pins: [PinData]
    
    var body: some View {
        TabView {
            // Dashboard Tab
            DashboardView(authManager: authManager, pins: pins)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            
            // Map Tab
            MapView(locationManager: locationManager, modelContext: modelContext)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            
            // Analytics Tab
            AnalyticsView(pins: pins)
                .tabItem {
                    Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            // Team Tab
            TeamView(authManager: authManager)
                .tabItem {
                    Label("Team", systemImage: "person.3.fill")
                }
        }
        .tint(.blue) // Consistent accent color
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(for: PinData.self, inMemory: true)
}
