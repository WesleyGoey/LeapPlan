//
//  LocationService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Combine
import CoreLocation
import Foundation

class LocationService: NSObject, ObservableObject, LocationServiceProtocol,
    CLLocationManagerDelegate
{
    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationPermission()
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Gagal mendapatkan lokasi GPS: \(error.localizedDescription)")
    }
}
