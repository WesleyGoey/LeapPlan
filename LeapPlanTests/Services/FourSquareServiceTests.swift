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

    func testFetchTrendingPlaces_ShouldCallRepo() async throws {
        mockRepo.mockPlaces = [
            FSQPlace(
                fsq_place_id: "1",
                name: "Test",
                distance: 10,
                latitude: 0,
                longitude: 0,
                location: nil,
                rating: 5,
                stats: nil,
                imageURL: nil
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
            latitude: 0,
            longitude: 0,
            location: nil,
            rating: 5.0,
            stats: nil,
            imageURL: nil
        )
    }

    // MARK: - Test Semua Fungsi

    func testFetchTrendingPlaces_AttachesPhotosCorrectly() async throws {
        mockRepo.mockPlaces = [createDummyPlace(id: "1")]
        mockRepo.mockPhotoURL = "https://test.com/photo.jpg"

        let results = try await service.fetchTrendingPlaces(city: "Jakarta")

        XCTAssertTrue(mockRepo.didCallFetchPlaces)
        XCTAssertEqual(results.first?.imageURL, "https://test.com/photo.jpg")
    }

    func testSearchPlaces_AttachesPhotosCorrectly() async throws {
        mockRepo.mockPlaces = [createDummyPlace(id: "2")]
        mockRepo.mockPhotoURL = "https://test.com/search.jpg"

        let results = try await service.searchPlaces(
            query: "Cafe",
            latitude: 0,
            longitude: 0
        )

        XCTAssertTrue(mockRepo.didCallSearchPlaces)
        XCTAssertEqual(results.first?.imageURL, "https://test.com/search.jpg")
    }

    func testFetchPlaces_AttachesPhotosCorrectly() async throws {
        mockRepo.mockPlaces = [createDummyPlace(id: "3")]
        mockRepo.mockPhotoURL = "https://test.com/fetch.jpg"

        let results = try await service.fetchPlaces(
            near: "Bali",
            categoryID: "123",
            limit: 5
        )

        XCTAssertTrue(mockRepo.didCallFetchPlaces)
        XCTAssertEqual(results.first?.imageURL, "https://test.com/fetch.jpg")
    }

    func testSearchPlacesByCity_AttachesPhotosCorrectly() async throws {
        mockRepo.mockPlaces = [createDummyPlace(id: "4")]
        mockRepo.mockPhotoURL = "https://test.com/city.jpg"

        let results = try await service.searchPlacesByCity(
            near: "Surabaya",
            query: "Taman",
            limit: 5
        )

        XCTAssertTrue(mockRepo.didCallSearchPlacesByCity)
        XCTAssertEqual(results.first?.imageURL, "https://test.com/city.jpg")
    }

    func testAutocomplete_DoesNotAttachPhotos() async throws {
        // Autocomplete tidak pakai TaskGroup attachPhotos, jadi harus nil
        mockRepo.mockPlaces = [createDummyPlace(id: "5")]

        let results = try await service.autocompleteLocation(query: "Sura")

        XCTAssertTrue(mockRepo.didCallAutocompleteLocation)
        XCTAssertNil(
            results.first?.imageURL,
            "Autocomplete tidak boleh ada imageURL"
        )
    }

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
