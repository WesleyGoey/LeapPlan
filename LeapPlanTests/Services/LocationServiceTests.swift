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
        // Inisialisasi Service Asli
        service = LocationService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Test Delegate Logic

    func testDidUpdateLocations() {
        // Arrange
        let dummyCoordinate = CLLocationCoordinate2D(
            latitude: -7.2575,
            longitude: 112.7521
        )
        let dummyLocation = CLLocation(
            latitude: dummyCoordinate.latitude,
            longitude: dummyCoordinate.longitude
        )

        // Act: Memanggil fungsi delegate secara manual
        service.locationManager(
            CLLocationManager(),
            didUpdateLocations: [dummyLocation]
        )

        // Assert: Pastikan lokasi ter-update
        // Kita gunakan expectation karena DispatchQueue.main.async mungkin butuh waktu
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

    func testDidUpdateLocationsWithEmptyArray() {
        // Arrange
        service.currentLocation = nil

        // Act: Panggil dengan array kosong
        service.locationManager(CLLocationManager(), didUpdateLocations: [])

        // Assert
        XCTAssertNil(
            service.currentLocation,
            "Lokasi tidak boleh berubah jika array kosong"
        )
    }

    func testInitialization() {
        XCTAssertNotNil(service)
    }

    func testDidFailWithError() {
        // Act & Assert
        // Kita cukup memanggil fungsinya untuk memastikan tidak ada crash/error
        let error = NSError(domain: "GPS", code: 1, userInfo: nil)
        service.locationManager(CLLocationManager(), didFailWithError: error)

        // Tidak ada assert spesifik karena fungsi hanya nge-print,
        // tapi jika test ini lewat, berarti kodenya aman.
        XCTAssertTrue(true)
    }
}
