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

    // MARK: - Test Add Place to Trip
    func testAddPlaceToTrip() async throws {
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
            location: nil
        )

        let plan = DayPlan(
            id: "p1",
            dayNumber: 1,
            date: Date(),
            destinations: []
        )
        mockRepo.mockDayPlans = ["t1": [plan]]

        try await service.addPlaceToTrip(
            place: place,
            targetTrip: trip,
            selectedDays: [1],
            userID: "u1"
        )
        let savedPlansAfterAdd = mockRepo.mockDayPlans["t1"]
        let firstPlanAfterAdd = savedPlansAfterAdd?.first
        let destinationsCountAfterAdd = await firstPlanAfterAdd?.destinations
            .count
        let firstDestinationFoursquareID = await firstPlanAfterAdd?.destinations
            .first?.foursquareID

        XCTAssertTrue(mockRepo.didCallSaveDayPlan)
        XCTAssertEqual(destinationsCountAfterAdd, 1)
        XCTAssertEqual(firstDestinationFoursquareID, "fsq1")
    }

    // MARK: - Test Remove Place from Trip
    func testRemovePlaceFromTrip() async throws {
        let dest = TripDestination(
            id: "d1",
            name: "Beach",
            category: "Wisata",
            foursquareID: "fsq1",
            latitude: 0,
            longitude: 0,
            orderIndex: 0,
            stayDurationMinutes: 60,
            transitTimeToNextMinutes: 10
        )
        let plan = DayPlan(
            id: "p1",
            dayNumber: 1,
            date: Date(),
            destinations: [dest]
        )
        mockRepo.mockDayPlans = ["t1": [plan]]

        try await service.removePlaceFromTrip(
            placeID: "fsq1",
            tripID: "t1",
            dayNum: 1,
            userID: "u1"
        )
        let savedPlansAfterRemove = mockRepo.mockDayPlans["t1"]
        let firstPlanAfterRemove = savedPlansAfterRemove?.first
        let destinationsCountAfterRemove = await firstPlanAfterRemove?
            .destinations.count

        XCTAssertTrue(mockRepo.didCallSaveDayPlan)
        XCTAssertEqual(
            destinationsCountAfterRemove,
            0,
            "Destinasi harusnya dihapus"
        )
    }

    // MARK: - Test Save Reordered Destinations
    func testSaveReorderedDestinations() async throws {
        let d1 = TripDestination(
            id: "d1",
            name: "A",
            category: "",
            foursquareID: "1",
            latitude: 0,
            longitude: 0,
            orderIndex: 1,
            stayDurationMinutes: 0,
            transitTimeToNextMinutes: 0
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
            transitTimeToNextMinutes: 0
        )
        let plan = DayPlan(
            id: "p1",
            dayNumber: 1,
            date: Date(),
            destinations: [d1, d2]
        )

        try await service.saveReorderedDestinations(
            dayPlan: plan,
            tripID: "t1",
            userID: "u1"
        )

        let savedPlan = mockRepo.mockDayPlans["t1"]?.first
        let firstOrderIndex = await savedPlan?.destinations[0].orderIndex
        let secondOrderIndex = await savedPlan?.destinations[1].orderIndex
        XCTAssertEqual(firstOrderIndex, 0)
        XCTAssertEqual(secondOrderIndex, 1)
    }

    // MARK: - Test Calculate Timeline
    func testCalculateTimeline() {
        let d1 = TripDestination(
            id: "d1",
            name: "A",
            category: "",
            foursquareID: "1",
            latitude: 0,
            longitude: 0,
            orderIndex: 0,
            stayDurationMinutes: 60,
            transitTimeToNextMinutes: 30
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
            transitTimeToNextMinutes: 0
        )
        let plan = DayPlan(
            id: "p1",
            dayNumber: 1,
            date: Date(),
            destinations: [d1, d2]
        )

        let timeline = service.calculateTimeline(for: d2, in: plan)
        XCTAssertEqual(timeline, "10:30 AM")
    }
}
