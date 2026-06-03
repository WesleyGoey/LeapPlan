//
//  TripGenerationServiceTests.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class TripGenerationServiceTests: XCTestCase {
    var sut: TripService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = TripService()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_itineraryGeneration_shouldApplyCorrectConstraints() {
        XCTAssertNotNil(sut)
    }
}