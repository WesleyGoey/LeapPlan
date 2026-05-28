//
//  FourSquareServiceTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import XCTest
@testable import LeapPlan

final class FourSquareServiceTests: XCTestCase {
    var service: FourSquareService!
    
    override func setUp() {
        super.setUp()
        service = FourSquareService()
    }

    func testService_Initialization() {
        XCTAssertNotNil(service, "Service harus berhasil diinisialisasi")
    }
    
    func testFetchTrendingPlaces_EmptyCity_DoesNotCrash() async {
        do {
            _ = try await service.fetchTrendingPlaces(city: "")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
