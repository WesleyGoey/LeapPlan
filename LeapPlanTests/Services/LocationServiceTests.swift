//
//  LocationServiceTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import CoreLocation
import XCTest

@testable import LeapPlan

final class LocationServiceTests: XCTestCase {

    var service: LocationService!

    override func setUp() {
        super.setUp()
        service = LocationService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Test Location Updates
    func testDidUpdateLocations() {
        let dummyCoordinate = CLLocationCoordinate2D(
            latitude: -7.2575,
            longitude: 112.7521
        )
        let dummyLocation = CLLocation(
            latitude: dummyCoordinate.latitude,
            longitude: dummyCoordinate.longitude
        )

        service.locationManager(
            CLLocationManager(),
            didUpdateLocations: [dummyLocation]
        )

        let expectation = XCTestExpectation(
            description: "Wait for main queue update"
        )

        DispatchQueue.main.async {
            XCTAssertEqual(
                self.service.currentLocation?.latitude,
                dummyCoordinate.latitude
            )
            XCTAssertEqual(
                self.service.currentLocation?.longitude,
                dummyCoordinate.longitude
            )
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Test Empty Locations Array
    func testDidUpdateLocationsWithEmptyArray() {
        service.currentLocation = nil

        service.locationManager(CLLocationManager(), didUpdateLocations: [])

        XCTAssertNil(
            service.currentLocation,
            "Lokasi tidak boleh berubah jika array kosong"
        )
    }

    // MARK: - Test InitializationT
    func testInitialization() {
        XCTAssertNotNil(service)
    }

    // MARK: - Test Error Handling
    func testDidFailWithError() {
        let error = NSError(domain: "GPS", code: 1, userInfo: nil)
        service.locationManager(CLLocationManager(), didFailWithError: error)

        XCTAssertTrue(true)
    }
}
