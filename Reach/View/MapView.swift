//
//  MapView.swift
//  Reach
//
//  Enhanced following Apple HIG
//

import SwiftUI
import MapKit
import UIKit

// MARK: - MKCoordinateRegion Extension
extension MKCoordinateRegion {
    static let sfsu = MKCoordinateRegion(
        center: .init(latitude: 37.720663784, longitude: -122.474498102),
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
    )
}

// MARK: - CLLocationCoordinate2D Extension
extension CLLocationCoordinate2D {
    static let school = CLLocationCoordinate2D(
        latitude: 37.720663784,
        longitude: -122.474498102
    )
}

/// Map view for displaying outreach locations and dropping pins
struct MapView: View {
    // MARK: - Properties
    
    @Binding var pins: [PinData]
    @ObservedObject var locationManager: LocationManager
    @State private var showingPinEntry = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedPin: PinData?
    @State private var showingLocationAlert = false
    @State private var showingPinDetail = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: .school,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Map View
                mapLayer
                
                // Control Panel
                if locationManager.authorizationStatus != .denied &&
                   locationManager.authorizationStatus != .restricted {
                    controlPanel
                }
                
                // Location Permission Overlay
                if locationManager.authorizationStatus == .denied ||
                   locationManager.authorizationStatus == .restricted {
                    locationDeniedOverlay
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            withAnimation {
                                cameraPosition = .automatic
                            }
                        } label: {
                            Label("Show All Pins", systemImage: "map")
                        }
                        
                        if let location = locationManager.location {
                            Button {
                                centerOnLocation(location)
                            } label: {
                                Label("My Location", systemImage: "location.fill")
                            }
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            pins.removeAll()
                        } label: {
                            Label("Clear All Pins", systemImage: "trash")
                        }
                        .disabled(pins.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingPinEntry) {
                if let coordinate = selectedCoordinate {
                    PinDataEntryView(
                        isPresented: $showingPinEntry,
                        coordinate: coordinate,
                        onSave: { pinData in
                            pins.append(pinData)
                        }
                    )
                }
            }
            .sheet(isPresented: $showingPinDetail) {
                if let pin = selectedPin {
                    PinDetailView(pin: pin, isPresented: $showingPinDetail)
                }
            }
            .alert("Location Access Required", isPresented: $showingLocationAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enable location services in Settings to see your current position and use map features.")
            }
            .onAppear {
                requestLocationPermissionIfNeeded()
            }
            .onChange(of: locationManager.location?.latitude) { _, _ in
                if let location = locationManager.location {
                    centerOnLocation(location)
                }
            }
            .onChange(of: locationManager.location?.longitude) { _, _ in
                if let location = locationManager.location {
                    centerOnLocation(location)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            // User location
            if let location = locationManager.location {
                Annotation("You", coordinate: location) {
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .fill(.blue)
                            .frame(width: 16, height: 16)
                            .overlay {
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            }
                    }
                }
            }
            
            // Pins
            ForEach(pins) { pin in
                Annotation(pin.residenceType.rawValue, coordinate: pin.coordinate) {
                    PinAnnotationView(pin: pin)
                        .onTapGesture {
                            selectedPin = pin
                            showingPinDetail = true
                        }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
    
    private var controlPanel: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Pin count badge
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.blue)
                    Text("\(pins.count) pins")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(.regularMaterial)
                }
                
                Spacer()
                
                // Add pin button
                Button {
                    if let location = locationManager.location {
                        selectedCoordinate = location
                    } else {
                        selectedCoordinate = .school
                    }
                    showingPinEntry = true
                } label: {
                    Label("Add Pin", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private var locationDeniedOverlay: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "location.slash.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange.gradient)
                
                VStack(spacing: 8) {
                    Text("Location Access Required")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Enable location services to see your position and track outreach visits")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    showingLocationAlert = true
                } label: {
                    Text("Enable in Settings")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.regularMaterial)
            }
            .padding()
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func requestLocationPermissionIfNeeded() {
        if locationManager.shouldRequestPermission {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                locationManager.requestPermission()
            }
        }
    }
    
    private func centerOnLocation(_ location: CLLocationCoordinate2D) {
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }
}

// MARK: - Supporting Views

struct PinAnnotationView: View {
    let pin: PinData
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(pinColor.gradient)
                    .frame(width: 36, height: 36)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Image(systemName: pinIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            Text(pin.residenceType.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background {
                    Capsule()
                        .fill(.background)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
        }
    }
    
    private var pinIcon: String {
        switch pin.residenceType {
        case .house: return "house.fill"
        case .apartment: return "building.2.fill"
        case .hotel: return "bed.double.fill"
        case .duplex: return "building.fill"
        case .other: return "mappin"
        }
    }
    
    private var pinColor: Color {
        if pin.answerStatus == .answered {
            return pin.responseType == .positive ? .green : .red
        } else {
            return .orange
        }
    }
}

struct PinDetailView: View {
    let pin: PinData
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Residence Type", value: pin.residenceType.rawValue)
                    LabeledContent("Status", value: pin.answerStatus.rawValue)
                    if pin.answerStatus == .answered {
                        LabeledContent("Response", value: pin.responseType.rawValue)
                    }
                }
                
                Section("Location") {
                    LabeledContent("Latitude", value: String(format: "%.6f", pin.latitude))
                    LabeledContent("Longitude", value: String(format: "%.6f", pin.longitude))
                }
                
                Section("Details") {
                    LabeledContent("Date", value: pin.timestamp.formatted(date: .abbreviated, time: .shortened))
                    
                    if let notes = pin.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(notes)
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
        }
    }
}

// MARK: - Preview
#Preview {
    MapView(
        pins: .constant([
            PinData(coordinate: .school, residenceType: .house, answerStatus: .answered, responseType: .positive)
        ]),
        locationManager: LocationManager()
    )
}
