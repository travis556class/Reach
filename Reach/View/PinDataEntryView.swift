//
//  PinDataEntryView.swift
//  Reach
//
//  Enhanced following Apple HIG with SwiftData
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct PinDataEntryView: View {
    @Binding var isPresented: Bool
    let coordinate: CLLocationCoordinate2D
    var modelContext: ModelContext
    
    @StateObject private var locationManager = LocationManager()
    @State private var workingLatitude: Double
    @State private var workingLongitude: Double
    @State private var awaitingLocationUpdate = false
    @State private var selectedResidenceType: ResidenceType = .house
    @State private var selectedAnswerStatus: AnswerStatus = .answered
    @State private var selectedResponseType: ResponseType = .positive
    @State private var notes: String = ""
    @FocusState private var notesFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(isPresented: Binding<Bool>, coordinate: CLLocationCoordinate2D, modelContext: ModelContext) {
        self._isPresented = isPresented
        self.coordinate = coordinate
        self.modelContext = modelContext
        self._workingLatitude = State(initialValue: coordinate.latitude)
        self._workingLongitude = State(initialValue: coordinate.longitude)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Latitude")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "%.6f", workingLatitude))
                            .monospacedDigit()
                    }
                    
                    HStack {
                        Text("Longitude")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "%.6f", workingLongitude))
                            .monospacedDigit()
                    }
                    
                    Button {
                        updateToCurrentLocation()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Use Current Location")
                        }
                    }
                    .disabled(awaitingLocationUpdate)
                } header: {
                    Text("Location")
                } footer: {
                    if awaitingLocationUpdate {
                        HStack {
                            ProgressView()
                                .controlSize(.small)
                            Text("Getting location...")
                                .font(.caption)
                        }
                    }
                }
                
                Section("Residence Information") {
                    Picker("Type", selection: $selectedResidenceType) {
                        ForEach(ResidenceType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: iconFor(residenceType: type))
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section("Contact Information") {
                    Picker("Answer Status", selection: $selectedAnswerStatus) {
                        ForEach(AnswerStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedAnswerStatus == .answered {
                        Picker("Response", selection: $selectedResponseType) {
                            ForEach(ResponseType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: iconFor(responseType: type))
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Section {
                    TextField("Additional details (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                        .focused($notesFieldFocused)
                } header: {
                    Text("Notes")
                } footer: {
                    Text("Add any relevant information about the visit")
                }
            }
            .navigationTitle("Add Pin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePin()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            notesFieldFocused = false
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .onAppear {
                // Initialize with provided coordinate
                workingLatitude = coordinate.latitude
                workingLongitude = coordinate.longitude
            }
            .onChange(of: locationManager.location?.latitude) { oldValue, newValue in
                guard awaitingLocationUpdate,
                      let latitude = newValue,
                      let longitude = locationManager.location?.longitude else { return }
                withAnimation {
                    workingLatitude = latitude
                    workingLongitude = longitude
                    awaitingLocationUpdate = false
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateToCurrentLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            awaitingLocationUpdate = true
            locationManager.requestPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = locationManager.location {
                withAnimation {
                    workingLatitude = location.latitude
                    workingLongitude = location.longitude
                }
            } else {
                awaitingLocationUpdate = true
                locationManager.requestLocation()
            }
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
    private func savePin() {
        let pinData = PinData(
            coordinate: CLLocationCoordinate2D(
                latitude: workingLatitude,
                longitude: workingLongitude
            ),
            residenceType: selectedResidenceType,
            answerStatus: selectedAnswerStatus,
            responseType: selectedResponseType,
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(pinData)
        try? modelContext.save()
        dismiss()
    }
    
    private func iconFor(residenceType: ResidenceType) -> String {
        switch residenceType {
        case .house: return "house.fill"
        case .apartment: return "building.2.fill"
        case .hotel: return "bed.double.fill"
        case .duplex: return "building.fill"
        case .other: return "mappin.circle"
        }
    }
    
    private func iconFor(responseType: ResponseType) -> String {
        switch responseType {
        case .positive: return "hand.thumbsup.fill"
        case .negative: return "hand.thumbsdown.fill"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PinData.self, configurations: config)
    
    return PinDataEntryView(
        isPresented: .constant(true),
        coordinate: CLLocationCoordinate2D(latitude: 37.720663784, longitude: -122.474498102),
        modelContext: container.mainContext
    )
    .modelContainer(container)
}
