//
//  LocationManager.swift
//  Reach
//
//  Created by xCode on 9/10/25.
//

import Foundation
import CoreLocation
import MapKit

/// Location manager for handling GPS permissions and tracking
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published Properties
    
    @Published var location: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var shouldRequestPermission = false
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus()
    }
    
    // MARK: - Methods
    
    /// Checks the current authorization status and updates shouldRequestPermission
    func checkAuthorizationStatus() {
        authorizationStatus = locationManager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            shouldRequestPermission = true
        case .authorizedWhenInUse, .authorizedAlways:
            shouldRequestPermission = false
            requestLocation()
        case .denied, .restricted:
            shouldRequestPermission = false
        @unknown default:
            break
        }
    }
    
    /// Requests location permission from the user
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Starts updating the user's location
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.location = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
}
