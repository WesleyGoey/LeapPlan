//
//  LocationService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location
        locationManager.stopUpdatingLocation() // Hemat baterai
    }
}
