//
//  MockLocationService.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Foundation
import CoreLocation
@testable import LeapPlan

class MockLocationService: LocationServiceProtocol {
    // Menggunakan koordinat dummy (Surabaya secara default)
    var currentLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7688)
    var didCallRequestPermission = false

    func requestLocationPermission() {
        didCallRequestPermission = true
    }
}
