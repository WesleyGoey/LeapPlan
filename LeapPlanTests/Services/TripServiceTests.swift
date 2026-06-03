//
//  TripServiceTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import XCTest

@testable import LeapPlan

final class TripServiceTests: XCTestCase {

    var service: TripService!
    var mockFourSquareService: MockFourSquareService!
    var mockFirestoreRepo: MockFirestoreRepository!

    override func setUp() {
        super.setUp()
        mockFourSquareService = MockFourSquareService()
        mockFirestoreRepo = MockFirestoreRepository()

        service = TripService(
            foursquareService: mockFourSquareService,
            firestoreRepo: mockFirestoreRepo
        )
    }

    override func tearDown() {
        service = nil
        mockFourSquareService = nil
        mockFirestoreRepo = nil
        super.tearDown()
    }

    // MARK: - Test Cases

    func testGenerateRandomItinerary_FiltersInvalidPlaces() async throws {
        let rawPlaces = [
            FSQPlace(
                fsq_place_id: "1",
                name: "Pantai Indah",
                distance: 0,
                latitude: 0,
                longitude: 0,
                location: nil,
                rating: 5.0,
                stats: nil
            ),
            FSQPlace(
                fsq_place_id: "2",
                name: "Indomaret Point",
                distance: 0,
                latitude: 0,
                longitude: 0,
                location: nil,
                rating: 5.0,
                stats: nil
            ),  // Harus dihapus
            FSQPlace(
                fsq_place_id: "3",
                name: "Cafe Hits",
                distance: 0,
                latitude: 0,
                longitude: 0,
                location: nil,
                rating: 5.0,
                stats: nil
            ),  // Harus dihapus
        ]
        mockFourSquareService.mockPlaces = rawPlaces

        let prefs = RandomTripPreferences(
            locationName: "Surabaya",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 3),
            dailyPreferences: [
                DailyPreference(dayNumber: 1, meals: 1, places: 1)
            ]
        )

        // Act
        let result = try await service.generateRandomItinerary(
            preferences: prefs
        )

        // Assert
        // Seharusnya hanya "Pantai Indah" yang tersisa (count 1)
        let firstDestinationsCount: Int = await MainActor.run {
            result.first?.destinations.count ?? 0
        }
        let firstDestinationName: String? = await MainActor.run {
            result.first?.destinations.first?.name
        }
        XCTAssertEqual(firstDestinationsCount, 1)
        XCTAssertEqual(firstDestinationName, "Pantai Indah")
    }

    func testGenerateRandomItinerary_CreatesCorrectStructure() async throws {
        // Arrange
        let place = FSQPlace(
            fsq_place_id: "1",
            name: "Wisata A",
            distance: 0,
            latitude: 0,
            longitude: 0,
            location: nil,
            rating: 5.0,
            stats: nil
        )
        mockFourSquareService.mockPlaces = [place]

        let prefs = RandomTripPreferences(
            locationName: "Surabaya",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 3),
            dailyPreferences: [
                DailyPreference(dayNumber: 1, meals: 1, places: 1),
                DailyPreference(dayNumber: 2, meals: 3, places: 0),
            ]
        )

        // Act
        let result = try await service.generateRandomItinerary(
            preferences: prefs
        )

        // Assert
        XCTAssertEqual(result.count, 2, "Harus menghasilkan 2 hari perjalanan")
        let firstDayNumber: Int = await MainActor.run { result[0].dayNumber }
        let secondDayNumber: Int = await MainActor.run { result[1].dayNumber }
        XCTAssertEqual(firstDayNumber, 1)
        XCTAssertEqual(secondDayNumber, 2)
        let isSecondDayDestinationsEmpty: Bool = await MainActor.run {
            result[1].destinations.isEmpty
        }
        XCTAssertTrue(
            isSecondDayDestinationsEmpty,
            "Hari kedua seharusnya tidak ada destinasi sesuai prefs"
        )
    }

    func testGenerateRandomItinerary_HandlesError() async {
        // Arrange
        mockFourSquareService.shouldThrowError = true  // Misal API Foursquare mati

        let prefs = RandomTripPreferences(
            locationName: "Surabaya",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 3),
            dailyPreferences: []
        )

        // Act & Assert
        do {
            _ = try await service.generateRandomItinerary(preferences: prefs)
            XCTFail("Harusnya melempar error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
