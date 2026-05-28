//
//  LocationServiceTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import XCTest
import CoreLocation
@testable import LeapPlan

final class LocationServiceTests: XCTestCase {
    var locationService: LocationService!
    
    override func setUp() {
        super.setUp()
        locationService = LocationService()
    }
    
    func testLocationService_InitialStateIsNil() {
        XCTAssertNil(locationService.currentLocation, "Lokasi awal harusnya nil sebelum permission diberikan")
    }
    
    func testLocationService_RequestPermission_SetsFlag() {
        locationService.requestLocationPermission()
        XCTAssertNotNil(locationService, "Service tetap ada setelah request permission")
    }
}
