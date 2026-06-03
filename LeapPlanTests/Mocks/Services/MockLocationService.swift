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
    var stubbedLocation: CLLocation? = CLLocation(latitude: -7.250445, longitude: 112.768845) // Surabaya
    var requestLocationCalled = false
    
    func requestLocationPermission() {
        requestLocationCalled = true
    }
    
    func getCurrentLocation() -> CLLocation? {
        return stubbedLocation
    }
}