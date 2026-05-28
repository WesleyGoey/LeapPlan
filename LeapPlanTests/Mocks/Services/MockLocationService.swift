//
//  MockLocationService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import CoreLocation
@testable import LeapPlan

class MockLocationService: LocationServiceProtocol {
    var currentLocation: CLLocation? = CLLocation(latitude: -7.2504, longitude: 112.7688)
    var permissionRequested = false
    
    func requestLocationPermission() {
        permissionRequested = true
    }
}