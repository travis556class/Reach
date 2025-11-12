//
//  PinDataEntryView.swift
//  Reach
//
//  Created by xCode on 9/10/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct PinDataEntryView: View {
    @Binding var isPresented: Bool
    let coordinate: CLLocationCoordinate2D
    let onSave: (PinData) -> Void
    
    @StateObject private var locationManager = LocationManager()
    @State private var workingLatitude: Double = 0
    @State private var workingLongitude: Double = 0
    @State private var awaitingLocationUpdate = false
    @State private var selectedResidenceType: ResidenceType = .house
    @State private var selectedAnswerStatus: AnswerStatus = .answered
    @State private var selectedResponseType: ResponseType = .positive
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Location")) {
                    HStack {
                        Text("Latitude:")
                        Spacer()
                        Text(String(format: "%.6f", workingLatitude))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Longitude:")
                        Spacer()
                        Text(String(format: "%.6f", workingLongitude))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Button("Use Current Location"){
                            switch locationManager.authorizationStatus {
                            case .notDetermined:
                                awaitingLocationUpdate = true
                                locationManager.requestPermission()
                            case .authorizedWhenInUse, .authorizedAlways:
                                if let loc = locationManager.location {
                                    workingLatitude = loc.latitude
                                    workingLongitude = loc.longitude
                                } else {
                                    awaitingLocationUpdate = true
                                    locationManager.requestLocation()
                                }
                            case .denied, .restricted:
                                // No permission; do nothing here (MapView handles alert). Optionally guide user.
                                break
                            @unknown default:
                                break
                            }
                        }
                    }
                }
                
                Section(header: Text("Residence Information")) {
                    Picker("Residence Type", selection: $selectedResidenceType) {
                        ForEach(ResidenceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Contact Information")) {
                    Picker("Answer Status", selection: $selectedAnswerStatus) {
                        ForEach(AnswerStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Response Type", selection: $selectedResponseType) {
                        ForEach(ResponseType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Notes")) {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Pin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let pinData = PinData(
                            coordinate: CLLocationCoordinate2D(latitude: workingLatitude, longitude: workingLongitude),
                            residenceType: selectedResidenceType,
                            answerStatus: selectedAnswerStatus,
                            responseType: selectedResponseType,
                            notes: notes.isEmpty ? nil : notes
                        )
                        onSave(pinData)
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                // Initialize with provided coordinate
                workingLatitude = coordinate.latitude
                workingLongitude = coordinate.longitude
            }
            .onChange(of: locationManager.location?.latitude) {
                guard awaitingLocationUpdate, let loc = locationManager.location else { return }
                workingLatitude = loc.latitude
                workingLongitude = loc.longitude
                awaitingLocationUpdate = false
            }
            .onChange(of: locationManager.location?.longitude) {
                guard awaitingLocationUpdate, let loc = locationManager.location else { return }
                workingLatitude = loc.latitude
                workingLongitude = loc.longitude
                awaitingLocationUpdate = false
            }
        }
    }
}

#Preview {
    PinDataEntryView(
        isPresented: .constant(true),
        coordinate: CLLocationCoordinate2D(latitude: 37.720663784, longitude: -122.474498102),
        onSave: { _ in }
    )
}

