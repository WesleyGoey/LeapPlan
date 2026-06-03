//
//  TripDestinationServiceTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import XCTest

@testable import LeapPlan

final class TripDestinationServiceTests: XCTestCase {

    var service: TripDestinationService!
    var mockRepo: MockFirestoreRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockFirestoreRepository()
        service = TripDestinationService(firestoreRepo: mockRepo)
    }

    override func tearDown() {
        service = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - Test Functions

    func testAddPlaceToTrip() async throws {
        // Arrange
        let trip = Trip(
            id: "t1",
            title: "Bali",
            locationName: "Bali",
            startDate: Date(),
            endDate: Date(),
            status: .upcoming,
            participantIDs: [],
            createdAt: Date(),
            createdBy: "u1"
        )
        let place = FSQPlace(
            fsq_place_id: "fsq1",
            name: "Beach",
            distance: 0,
            latitude: 0,
            longitude: 0,
            location: nil,
            rating: 5.0,
            stats: nil
        )

        let plan = DayPlan(
            id: "p1",
            dayNumber: 1,
            date: Date(),
            destinations: []
        )
        mockRepo.mockDayPlans = ["t1": [plan]]

        // Act
        try await service.addPlaceToTrip(
            place: place,
            targetTrip: trip,
            selectedDays: [1],
            userID: "u1"
        )

        // Assert
        XCTAssertTrue(mockRepo.didCallSaveDayPlan)
        XCTAssertEqual(
            mockRepo.mockDayPlans["t1"]?.first?.destinations.count,
            1
        )
        XCTAssertEqual(
            mockRepo.mockDayPlans["t1"]?.first?.destinations.first?
                .foursquareID,
            "fsq1"
        )
    }

    func testRemovePlaceFromTrip() async throws {
        // Arrange
        let dest = TripDestination(
            id: "d1",
            name: "Beach",
            category: "Wisata",
            foursquareID: "fsq1",
            latitude: 0,
            longitude: 0,
            orderIndex: 0,
            stayDurationMinutes: 60,
            transitTimeToNextMinutes: 10,
            imageURL: nil
        )
        let plan = DayPlan(
            id: "p1",
            dayNumber: 1,
            date: Date(),
            destinations: [dest]
        )
        mockRepo.mockDayPlans = ["t1": [plan]]

        // Act
        try await service.removePlaceFromTrip(
            placeID: "fsq1",
            tripID: "t1",
            dayNum: 1,
            userID: "u1"
        )

        // Assert
        XCTAssertTrue(mockRepo.didCallSaveDayPlan)
        XCTAssertEqual(
            mockRepo.mockDayPlans["t1"]?.first?.destinations.count,
            0,
            "Destinasi harusnya dihapus"
        )
    }

    func testSaveReorderedDestinations() async throws {
        // Arrange
        let d1 = TripDestination(
            id: "d1",
            name: "A",
            category: "",
            foursquareID: "1",
            latitude: 0,
            longitude: 0,
            orderIndex: 1,
            stayDurationMinutes: 0,
            transitTimeToNextMinutes: 0,
            imageURL: nil
        )
        let d2 = TripDestination(
            id: "d2",
            name: "B",
            category: "",
            foursquareID: "2",
            latitude: 0,
            longitude: 0,
            orderIndex: 0,
            stayDurationMinutes: 0,
            transitTimeToNextMinutes: 0,
            imageURL: nil
        )
        let plan = DayPlan(
            id: "p1",
            dayNumber: 1,
            date: Date(),
            destinations: [d1, d2]
        )  // Urutan salah (1, 0)

        // Act
        try await service.saveReorderedDestinations(
            dayPlan: plan,
            tripID: "t1",
            userID: "u1"
        )

        // Assert
        let savedPlan = mockRepo.mockDayPlans["t1"]?.first
        XCTAssertEqual(savedPlan?.destinations[0].orderIndex, 0)
        XCTAssertEqual(savedPlan?.destinations[1].orderIndex, 1)
    }

    func testCalculateTimeline() {
        // Arrange
        let d1 = TripDestination(
            id: "d1",
            name: "A",
            category: "",
            foursquareID: "1",
            latitude: 0,
            longitude: 0,
            orderIndex: 0,
            stayDurationMinutes: 60,
            transitTimeToNextMinutes: 30,
            imageURL: nil
        )
        let d2 = TripDestination(
            id: "d2",
            name: "B",
            category: "",
            foursquareID: "2",
            latitude: 0,
            longitude: 0,
            orderIndex: 1,
            stayDurationMinutes: 60,
            transitTimeToNextMinutes: 0,
            imageURL: nil
        )
        let plan = DayPlan(
            id: "p1",
            dayNumber: 1,
            date: Date(),
            destinations: [d1, d2]
        )

        // Act (d2 harusnya mulai jam 9:00 + 60min(d1 stay) + 30min(d1 transit) = 10:30)
        let timeline = service.calculateTimeline(for: d2, in: plan)

        // Assert
        XCTAssertEqual(timeline, "10:30 AM")
    }
}
