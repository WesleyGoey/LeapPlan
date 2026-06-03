//
//  MockLocationService.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import Combine
import CoreLocation
import Foundation

@testable import LeapPlan

class MockLocationService: ObservableObject, LocationServiceProtocol {
    @Published var currentLocation: CLLocationCoordinate2D?

    func setDummyLocation(lat: Double, lon: Double) {
        self.currentLocation = CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon
        )
    }

    func requestLocationPermission() {
        // null lol
    }
}
