//
//  FourSquareServiceTests.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class FourSquareServiceTests: XCTestCase {
    var sut: FourSquareService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = FourSquareService()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_service_shouldInitializeCorrectly() {
        XCTAssertNotNil(sut)
    }
}