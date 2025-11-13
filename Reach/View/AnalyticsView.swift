//
//  AnalyticsView.swift
//  Reach
//
//  Enhanced following Apple HIG
//

import Foundation
import SwiftUI
import Charts

/// Analytics and reporting view
struct AnalyticsView: View {
    let pins: [PinData]
    @State private var selectedTimeframe: Timeframe = .week
    @State private var showingExportSheet = false
    
    enum Timeframe: String, CaseIterable {
        case day = "Today"
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }
    
    // MARK: - Computed Properties
    
    private var filteredPins: [PinData] {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedTimeframe {
        case .day:
            return pins.filter { calendar.isDateInToday($0.timestamp) }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return pins.filter { $0.timestamp >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return pins.filter { $0.timestamp >= monthAgo }
        case .all:
            return pins
        }
    }
    
    private var residenceBreakdown: [(ResidenceType, Int)] {
        let grouped = Dictionary(grouping: filteredPins) { $0.residenceType }
        return ResidenceType.allCases.map { type in
            (type, grouped[type]?.count ?? 0)
        }
    }
    
    private var dailyVisits: [DailyVisit] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredPins) { pin in
            calendar.startOfDay(for: pin.timestamp)
        }
        return grouped.map { date, pins in
            DailyVisit(date: date, count: pins.count)
        }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if pins.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 20) {
                        // Timeframe Picker
                        timeframePicker
                        
                        // Key Metrics
                        keyMetricsGrid
                        
                        // Daily Trend Chart
                        if dailyVisits.count > 1 {
                            dailyTrendChart
                        }
                        
                        // Residence Type Breakdown
                        residenceTypeChart
                        
                        // Response Quality
                        responseQualitySection
                    }
                    .padding()
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(pins.isEmpty)
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportView(pins: filteredPins)
            }
        }
    }
    
    // MARK: - View Components
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 70))
                .foregroundStyle(.blue.gradient)
                .symbolEffect(.pulse)
            
            VStack(spacing: 12) {
                Text("No Data Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Analytics will appear here once you start adding pins to the map")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var timeframePicker: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var keyMetricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(
                title: "Total Visits",
                value: "\(filteredPins.count)",
                icon: "flag.checkered.2.crossed",
                color: .blue,
                trend: nil
            )
            
            MetricCard(
                title: "Response Rate",
                value: responseRateText,
                icon: "chart.line.uptrend.xyaxis",
                color: .green,
                trend: nil
            )
            
            MetricCard(
                title: "Positive Rate",
                value: positiveRateText,
                icon: "hand.thumbsup.fill",
                color: .mint,
                trend: nil
            )
            
            MetricCard(
                title: "Follow-ups",
                value: "\(filteredPins.filter { $0.answerStatus == .noAnswer }.count)",
                icon: "arrow.clockwise.circle.fill",
                color: .orange,
                trend: nil
            )
        }
    }
    
    private var dailyTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Visits")
                .font(.headline)
                .padding(.horizontal)
            
            Chart(dailyVisits) { visit in
                LineMark(
                    x: .value("Date", visit.date),
                    y: .value("Visits", visit.count)
                )
                .foregroundStyle(.blue.gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", visit.date),
                    y: .value("Visits", visit.count)
                )
                .foregroundStyle(.blue.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", visit.date),
                    y: .value("Visits", visit.count)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private var residenceTypeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Residence Types")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(residenceBreakdown, id: \.0) { type, count in
                    if count > 0 {
                        BarMark(
                            x: .value("Type", type.rawValue),
                            y: .value("Count", count)
                        )
                        .foregroundStyle(by: .value("Type", type.rawValue))
                        .annotation(position: .top) {
                            Text("\(count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                }
            }
            .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private var responseQualitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Response Quality")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                QualityRow(
                    label: "Answered",
                    count: filteredPins.filter { $0.answerStatus == .answered }.count,
                    total: filteredPins.count,
                    color: .green
                )
                
                QualityRow(
                    label: "No Answer",
                    count: filteredPins.filter { $0.answerStatus == .noAnswer }.count,
                    total: filteredPins.count,
                    color: .orange
                )
                
                Divider()
                
                let answeredPins = filteredPins.filter { $0.answerStatus == .answered }
                if !answeredPins.isEmpty {
                    QualityRow(
                        label: "Positive",
                        count: answeredPins.filter { $0.responseType == .positive }.count,
                        total: answeredPins.count,
                        color: .blue
                    )
                    
                    QualityRow(
                        label: "Negative",
                        count: answeredPins.filter { $0.responseType == .negative }.count,
                        total: answeredPins.count,
                        color: .red
                    )
                }
            }
            .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - Helper Properties
    
    private var responseRateText: String {
        guard !filteredPins.isEmpty else { return "0%" }
        let answered = filteredPins.filter { $0.answerStatus == .answered }.count
        let percentage = (Double(answered) / Double(filteredPins.count)) * 100
        return String(format: "%.0f%%", percentage)
    }
    
    private var positiveRateText: String {
        let answered = filteredPins.filter { $0.answerStatus == .answered }
        guard !answered.isEmpty else { return "0%" }
        let positive = answered.filter { $0.responseType == .positive }.count
        let percentage = (Double(positive) / Double(answered.count)) * 100
        return String(format: "%.0f%%", percentage)
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color.gradient)
                Spacer()
                if let trend = trend {
                    Text(trend)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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

struct QualityRow: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(count) / \(total)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(String(format: "%.0f%%", percentage * 100))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                    
                    Rectangle()
                        .fill(color.gradient)
                        .frame(width: geometry.size.width * percentage)
                }
                .frame(height: 8)
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
    }
}

struct ExportView: View {
    let pins: [PinData]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Export \(pins.count) visits as CSV")
                } header: {
                    Text("Export Format")
                }
                
                Section {
                    Button("Share Data") {
                        // Export logic would go here
                    }
                } header: {
                    Text("Export Options")
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Supporting Types

struct DailyVisit: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

// MARK: - Preview
#Preview("With Data") {
    AnalyticsView(pins: [
        PinData(coordinate: .school, residenceType: .house, answerStatus: .answered, responseType: .positive),
        PinData(coordinate: .school, residenceType: .apartment, answerStatus: .answered, responseType: .positive),
        PinData(coordinate: .school, residenceType: .house, answerStatus: .noAnswer, responseType: .positive)
    ])
}

#Preview("Empty") {
    AnalyticsView(pins: [])
}

