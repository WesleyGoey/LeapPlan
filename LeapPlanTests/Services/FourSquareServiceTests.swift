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

    // MARK: - Test Attach Photos
    func testFetchTrendingPlaces_WithPhotoAttachment() async throws {
        mockRepo.mockPlaces = [createDummyPlace(id: "1")]
        mockRepo.mockPhotoURL = "https://test.com/photo.jpg"

        let results = try await service.fetchTrendingPlaces(city: "Jakarta")

        XCTAssertTrue(mockRepo.didCallFetchPlaces)
        let imageURL1 = await MainActor.run { results.first?.imageURL }
        XCTAssertEqual(imageURL1, "https://test.com/photo.jpg")
    }

    // MARK: - Test Attach Photos for Search
    func testSearchPlaces_AttachesPhotosCorrectly() async throws {
        mockRepo.mockPlaces = [createDummyPlace(id: "2")]
        mockRepo.mockPhotoURL = "https://test.com/search.jpg"

        let results = try await service.searchPlaces(
            query: "Cafe",
            latitude: 0,
            longitude: 0
        )

        XCTAssertTrue(mockRepo.didCallSearchPlaces)
        let imageURL2 = await MainActor.run { results.first?.imageURL }
        XCTAssertEqual(imageURL2, "https://test.com/search.jpg")
    }

    // MARK: - Test Attach Photos for Other Methods
    func testFetchPlaces_AttachesPhotosCorrectly() async throws {
        mockRepo.mockPlaces = [createDummyPlace(id: "3")]
        mockRepo.mockPhotoURL = "https://test.com/fetch.jpg"

        let results = try await service.fetchPlaces(
            near: "Bali",
            categoryID: "123",
            limit: 5
        )

        XCTAssertTrue(mockRepo.didCallFetchPlaces)
        let imageURL3 = await MainActor.run { results.first?.imageURL }
        XCTAssertEqual(imageURL3, "https://test.com/fetch.jpg")
    }

    // MARK: - Test Attach Photos for City Search
    func testSearchPlacesByCity_AttachesPhotosCorrectly() async throws {
        mockRepo.mockPlaces = [createDummyPlace(id: "4")]
        mockRepo.mockPhotoURL = "https://test.com/city.jpg"

        let results = try await service.searchPlacesByCity(
            near: "Surabaya",
            query: "Taman",
            limit: 5
        )

        XCTAssertTrue(mockRepo.didCallSearchPlacesByCity)
        let imageURL4 = await MainActor.run { results.first?.imageURL }
        XCTAssertEqual(imageURL4, "https://test.com/city.jpg")
    }

    // MARK: - Test No Photo Attachment for Autocomplete
    func testAutocomplete_DoesNotAttachPhotos() async throws {
        mockRepo.mockPlaces = [createDummyPlace(id: "5")]

        let results = try await service.autocompleteLocation(query: "Sura")

        XCTAssertTrue(mockRepo.didCallAutocompleteLocation)
        let imageURL5 = await MainActor.run { results.first?.imageURL }
        XCTAssertNil(
            imageURL5,
            "Autocomplete tidak boleh ada imageURL"
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

