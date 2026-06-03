//
//  FirestoreRepositoryTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import XCTest

@testable import LeapPlan

@MainActor
final class FirestoreRepositoryTests: XCTestCase {

    var mockRepo: MockFirestoreRepository!
    let testUserID = "user_123"

    override func setUp() {
        super.setUp()
        mockRepo = MockFirestoreRepository()
    }

    // MARK: - Helper Data
    private func createDummyTrip() -> Trip {
        return Trip(
            id: "trip_1",
            title: "Bali",
            locationName: "Bali",
            startDate: Date(),
            endDate: Date(),
            status: .upcoming,
            participantIDs: [],
            createdAt: Date(),
            createdBy: testUserID
        )
    }

    // MARK: - Tests
    func testFetchTrips_ReturnsData() async throws {
        let trip = createDummyTrip()
        mockRepo.mockTrips[testUserID] = [trip]

        let trips = try await mockRepo.fetchTrips(forUserID: testUserID)

        XCTAssertTrue(mockRepo.didCallFetchTrips)
        XCTAssertEqual(trips.count, 1)
    }

    // MARK: - Test Create Trip
    func testCreateTrip_AddsToList() async throws {
        let trip = createDummyTrip()
        try await mockRepo.createTrip(trip, forUserID: testUserID)

        XCTAssertTrue(mockRepo.didCallCreateTrip)
        XCTAssertEqual(mockRepo.mockTrips[testUserID]?.count, 1)
    }

    // MARK: - Test Update Trip
    func testUpdateTrip_ModifiesData() async throws {
        var trip = createDummyTrip()
        try await mockRepo.createTrip(trip, forUserID: testUserID)

        await MainActor.run {
            trip.title = "Updated Name"
        }
        try await mockRepo.updateTrip(trip, forUserID: testUserID)

        let updatedTitle: String? = await MainActor.run {
            mockRepo.mockTrips[testUserID]?.first?.title
        }
        XCTAssertEqual(updatedTitle, "Updated Name")
    }

    // MARK: - Test Delete Trip
    func testDeleteTrip() async throws {
        let trip = createDummyTrip()
        try await mockRepo.createTrip(trip, forUserID: testUserID)

        try await mockRepo.deleteTrip(tripID: "trip_1", forUserID: testUserID)

        XCTAssertEqual(mockRepo.mockTrips[testUserID]?.count, 0)
    }

    // MARK: - Test Save and Fetch Day Plans
    func testSaveAndFetchDayPlans() async throws {
        let plan = DayPlan(
            id: "plan_1",
            dayNumber: 1,
            date: Date(),
            destinations: []
        )
        try await mockRepo.saveDayPlan(
            plan,
            forTripID: "trip_1",
            userID: testUserID
        )

        let fetched = try await mockRepo.fetchDayPlans(
            forTripID: "trip_1",
            userID: testUserID
        )

        XCTAssertEqual(fetched.first?.id, "plan_1")
    }

    // MARK: - Test Batch Save
    func testBatchSave() async throws {
        let trip = createDummyTrip()
        let plan = DayPlan(
            id: "plan_1",
            dayNumber: 1,
            date: Date(),
            destinations: []
        )

        try await mockRepo.saveGeneratedTripWithDayPlans(
            trip: trip,
            dayPlans: [plan],
            userID: testUserID
        )

        XCTAssertTrue(mockRepo.didCallSaveGeneratedTrip)
        XCTAssertEqual(mockRepo.mockTrips[testUserID]?.count, 1)
        XCTAssertEqual(
            mockRepo.mockDayPlans[mockRepo.mockTrips[testUserID]!.first!.id!]?
                .count,
            1
        )
    }
}
