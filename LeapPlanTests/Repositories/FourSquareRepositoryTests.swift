//
//  FourSquareRepositoryTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import XCTest

@testable import LeapPlan

final class FourSquareRepositoryTests: XCTestCase {

    var mockRepo: MockFourSquareRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockFourSquareRepository()
    }

    override func tearDown() {
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - Helper
    private func createDummyPlace() -> FSQPlace {
        return FSQPlace(
            fsq_place_id: "test_123",
            name: "Test Place",
            distance: 100,
            latitude: 0,
            longitude: 0,
            location: nil,
            rating: 5.0,
            stats: nil
        )
    }

    // MARK: - Test Search Places
    func testSearchPlaces_Success() async throws {
        let place = createDummyPlace()
        mockRepo.mockPlaces = [place]

        let results = try await mockRepo.searchPlaces(
            query: "Test",
            latitude: 0,
            longitude: 0
        )

        XCTAssertTrue(mockRepo.didCallSearchPlaces)
        XCTAssertEqual(results.count, 1)
        let firstName: String? = await MainActor.run { results.first?.name }
        XCTAssertEqual(firstName, "Test Place")
    }

    // MARK: - Test Search Places Fail
    func testSearchPlaces_Fail() async {
        mockRepo.shouldThrowError = true

        do {
            _ = try await mockRepo.searchPlaces(
                query: "Test",
                latitude: 0,
                longitude: 0
            )
            XCTFail("Harusnya melempar error")
        } catch {
            print(
                "DEBUG: Catch block reached. didCallSearchPlaces = \(mockRepo.didCallSearchPlaces)"
            )
            XCTAssertTrue(error is MockFourSquareRepository.MockError)
            XCTAssertTrue(mockRepo.didCallSearchPlaces)
        }
    }

    // MARK: - Test Fetch Photos
    func testFetchPhotos_Success() async throws {
        mockRepo.mockPhotoURL = "https://image.url"

        let url = try await mockRepo.fetchPlacePhotos(id: "123")

        XCTAssertEqual(url, "https://image.url")
    }
}
