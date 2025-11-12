//
//  AnalyticsView.swift
//  Reach
//
//  Created by Paradis d'Abbadon on 19.09.25.
//

import Foundation
import SwiftUI
import Charts

/// Analytics and reporting view
struct AnalyticsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("analytics & reports will be listed here")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                // Placeholder for analytics content
                VStack(spacing: 20) {
                    
                }
                
                Spacer()
            }
            //May stray from Navigation View
            .navigationTitle("Analytics")
        }
    }
}

#Preview {
    AnalyticsView()
}

