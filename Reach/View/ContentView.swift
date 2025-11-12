//
//  ContentView.swift
//  Reach
//
//  Created by xCode on 9/10/25.
//

import SwiftUI

/// Main content view that manages the app's tab navigation
struct ContentView: View {
    var body: some View {
        TabView {
            // Dashboard Tab
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }
            
            // Map Tab
            MapView()
                .tabItem { Label("Map", systemImage: "map.fill") }
            
            // Analytics Tab
            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.line.uptrend.xyaxis") }
            
            // Team Tab
            TeamView()
                .tabItem { Label("Team", systemImage: "person.3.fill") }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}