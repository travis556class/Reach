//
//  PinDetailView.swift
//  Reach
//
//  Created for viewing and managing individual pin details
//

import SwiftUI
import SwiftData
import MapKit

struct PinDetailView: View {
    let pin: PinData
    @Binding var isPresented: Bool
    var modelContext: ModelContext
    @State private var showingDeleteConfirmation = false
    @State private var showingEditView = false
    
    var body: some View {
        NavigationStack {
            List {
                // Pin Summary Section
                Section {
                    HStack {
                        Image(systemName: pinIcon)
                            .font(.title)
                            .foregroundStyle(pinColor.gradient)
                            .frame(width: 50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pin.residenceType.rawValue)
                                .font(.headline)
                            
                            HStack(spacing: 4) {
                                Image(systemName: statusIcon)
                                    .font(.caption)
                                Text(pin.answerStatus.rawValue)
                                    .font(.subheadline)
                            }
                            .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if pin.answerStatus == .answered {
                            VStack(alignment: .trailing, spacing: 4) {
                                Image(systemName: responseIcon)
                                    .font(.title3)
                                    .foregroundStyle(responseColor)
                                
                                Text(pin.responseType.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Contact Information
                Section("Contact Information") {
                    LabeledContent {
                        HStack {
                            Circle()
                                .fill(pin.answerStatus == .answered ? Color.green : Color.orange)
                                .frame(width: 8, height: 8)
                            Text(pin.answerStatus.rawValue)
                        }
                    } label: {
                        Label("Status", systemImage: "bell.fill")
                    }
                    
                    if pin.answerStatus == .answered {
                        LabeledContent {
                            HStack {
                                Circle()
                                    .fill(pin.responseType == .positive ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                                Text(pin.responseType.rawValue)
                            }
                        } label: {
                            Label("Response", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                    }
                }
                
                // Location Information
                Section("Location") {
                    LabeledContent("Latitude") {
                        Text(String(format: "%.6f", pin.latitude))
                            .monospacedDigit()
                            .font(.subheadline)
                    }
                    
                    LabeledContent("Longitude") {
                        Text(String(format: "%.6f", pin.longitude))
                            .monospacedDigit()
                            .font(.subheadline)
                    }
                    
                    Button {
                        openInMaps()
                    } label: {
                        Label("Open in Maps", systemImage: "map.fill")
                    }
                }
                
                // Visit Details
                Section("Visit Details") {
                    LabeledContent("Date", value: pin.timestamp.formatted(date: .abbreviated, time: .omitted))
                    LabeledContent("Time", value: pin.timestamp.formatted(date: .omitted, time: .shortened))
                    
                    if let notes = pin.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Notes", systemImage: "note.text")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            
                            Text(notes)
                                .font(.body)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color(.systemGray6))
                                }
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    }
                }
                
                // Actions Section
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("Delete Pin", systemImage: "trash")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Pin Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
            .confirmationDialog(
                "Delete Pin",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deletePin()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this pin? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var pinIcon: String {
        switch pin.residenceType {
        case .house: return "house.fill"
        case .apartment: return "building.2.fill"
        case .hotel: return "bed.double.fill"
        case .duplex: return "building.fill"
        case .other: return "mappin.circle"
        }
    }
    
    private var statusIcon: String {
        pin.answerStatus == .answered ? "checkmark.circle.fill" : "bell.slash.fill"
    }
    
    private var responseIcon: String {
        pin.responseType == .positive ? "hand.thumbsup.fill" : "hand.thumbsdown.fill"
    }
    
    private var pinColor: Color {
        if pin.answerStatus == .answered {
            return pin.responseType == .positive ? .green : .red
        } else {
            return .orange
        }
    }
    
    private var responseColor: Color {
        pin.responseType == .positive ? .green : .red
    }
    
    // MARK: - Helper Methods
    
    private func deletePin() {
        modelContext.delete(pin)
        try? modelContext.save()
        isPresented = false
    }
    
    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = pin.residenceType.rawValue
        mapItem.openInMaps(launchOptions: nil)
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PinData.self, configurations: config)
    let context = container.mainContext
    
    let samplePin = PinData(
        coordinate: CLLocationCoordinate2D(latitude: 37.720663784, longitude: -122.474498102),
        residenceType: .house,
        answerStatus: .answered,
        responseType: .positive,
        notes: "Very friendly resident, interested in learning more about our program."
    )
    context.insert(samplePin)
    
    return PinDetailView(
        pin: samplePin,
        isPresented: .constant(true),
        modelContext: context
    )
    .modelContainer(container)
}