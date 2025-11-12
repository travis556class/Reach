//
//  MapView.swift
//  Reach
//
//  Created by xCode on 9/10/25.
//

import SwiftUI
import MapKit
import UIKit

// MARK: - MKCoordinateRegion Extension
extension MKCoordinateRegion {
    /// SFSU campus coordinates as MKCoordinate
    static let sfsu = MKCoordinateRegion(center: .init(latitude: 37.720663784, longitude: -122.474498102), latitudinalMeters: 1000, longitudinalMeters: 1000)
}

// MARK: - CLLocationCoordinate2D Extension
extension CLLocationCoordinate2D {
    /// SFSU campus coordinates
    static let school = CLLocationCoordinate2D(latitude: 37.720663784, longitude: -122.474498102)
}

/// Map view for displaying outreach locations and dropping pins
struct MapView: View {
    // MARK: - Properties
    
    @StateObject private var locationManager = LocationManager()
    @State private var pins: [PinData] = []
    @State private var showingPinEntry = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showingLocationAlert = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: .school,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    @State private var currentMapCenter: CLLocationCoordinate2D = .school
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Map View
            mapLayer
            
            // Top Navigation Bar
            topNavigationBar
            
            // Floating Add Button
            floatingAddButton
            
            // Location Permission Overlay
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                locationDeniedOverlay
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
        .alert("Location Permission Required to Use Map Features", isPresented: $showingLocationAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable location services in Settings to use map features.")
        }
        .onAppear {
            requestLocationPermissionIfNeeded()
        }
        .onChange(of: locationManager.location?.latitude) {
            if let loc = locationManager.location { updateRegion(to: loc) }
        }
        .onChange(of: locationManager.location?.longitude) {
            if let loc = locationManager.location { updateRegion(to: loc) }
        }
    }
    
    // MARK: - View Components
    
    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            ForEach(pins) { pin in
                Annotation(pin.residenceType.rawValue, coordinate: pin.coordinate) {
                    VStack {
                        Image(systemName: pinIcon(for: pin))
                            .foregroundColor(pinColor(for: pin))
                            .font(.title2)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 30, height: 30)
                                    .shadow(radius: 3)
                            )
                        
                        Text(pin.residenceType.rawValue)
                            .font(.caption2)
                            .padding(2)
                            .background(.white)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea(.all, edges: .top)
    }
    
    private var topNavigationBar: some View {
        VStack {
            HStack {
                Text("Map")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.leading, 20)
                    .padding(.top, 8)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(.all, edges: .top)
            )
            .padding(.top, 0)
            
            Spacer()
        }
    }
    
    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    selectedCoordinate = currentMapCenter
                    showingPinEntry = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(.blue)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    private var locationDeniedOverlay: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "location.slash.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("Location Access Denied")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Enable location services to see your current position on the map.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    showingLocationAlert = true
                }) {
                    Text("Enable Location")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: 200)
                        .padding()
                        .background(.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .padding()
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    /// Requests location permission if needed
    private func requestLocationPermissionIfNeeded() {
        if locationManager.shouldRequestPermission {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                locationManager.requestPermission()
            }
        }
    }
    
    /// Updates the map region to the user's location
    private func updateRegion(to location: CLLocationCoordinate2D) {
        currentMapCenter = location
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }
    
    /// Returns the appropriate icon for a pin based on residence type
    private func pinIcon(for pin: PinData) -> String {
        switch pin.residenceType {
        case .house:
            return "house.fill"
        case .apartment:
            return "building.fill"
        case .hotel:
            return "building.2.fill"
        default:
            return "mappin.circle.fill"
        }
    }
    
    /// Returns the appropriate color for a pin based on answer and response status
    private func pinColor(for pin: PinData) -> Color {
        if pin.answerStatus == .answered {
            return pin.responseType == .positive ? .green : .red
        } else {
            return .orange
        }
    }
}

// MARK: - Preview
#Preview {
    MapView()
}
