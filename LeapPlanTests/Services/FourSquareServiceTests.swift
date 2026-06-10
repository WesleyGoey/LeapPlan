//
//  FourSquareServiceTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import XCTest

@testable import LeapPlan

final class FourSquareServiceTests: XCTestCase {

    var service: FourSquareService!
    var mockRepo: MockFourSquareRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockFourSquareRepository()
        service = FourSquareService(repo: mockRepo)
    }

    override func tearDown() {
        service = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - Test Trending Places
    func testFetchTrendingPlaces() async throws {
        mockRepo.mockPlaces = [
            FSQPlace(
                fsq_place_id: "1",
                name: "Test",
                distance: 10,
                location: nil,
            geocodes: FSQGeocodes(main: FSQCoordinate(latitude: 0, longitude: 0))
            )
        ]

        _ = try await service.fetchTrendingPlaces(city: "Bali")

        XCTAssertTrue(
            mockRepo.didCallFetchPlaces,
            "Harus memanggil didCallFetchPlaces"
        )
    }

    private func createDummyPlace(id: String) -> FSQPlace {
        return FSQPlace(
            fsq_place_id: id,
            name: "Test Place",
            distance: 100,
            location: nil,
            geocodes: FSQGeocodes(main: FSQCoordinate(latitude: 0, longitude: 0))
        )
    }



    // MARK: - Test Error Propagation
    func testService_ErrorPropagation() async {
        mockRepo.shouldThrowError = true

        do {
            _ = try await service.fetchTrendingPlaces(city: "ErrorCity")
            XCTFail("Harus melempar error")
        } catch {
            XCTAssertTrue(error is MockFourSquareRepository.MockError)
        }
    }
}

