//
//  LocationServiceTests.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class LocationServiceTests: XCTestCase {
    var sut: LocationService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = LocationService()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_service_shouldInitializeCorrectly() {
        XCTAssertNotNil(sut)
    }
}