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

    // MARK: - Test Cases
    func testSearchPlaces_Success() async throws {
        // Arrange
        let place = createDummyPlace()
        mockRepo.mockPlaces = [place]

        // Act
        let results = try await mockRepo.searchPlaces(
            query: "Test",
            latitude: 0,
            longitude: 0
        )

        // Assert
        XCTAssertTrue(mockRepo.didCallSearchPlaces)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Test Place")
    }

    func testSearchPlaces_Failure() async {
        // Arrange
        mockRepo.shouldThrowError = true

        // Act & Assert
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

    func testFetchPhotos_Success() async throws {
        // Arrange
        mockRepo.mockPhotoURL = "https://image.url"

        // Act
        let url = try await mockRepo.fetchPlacePhotos(id: "123")

        // Assert
        XCTAssertEqual(url, "https://image.url")
    }
}
