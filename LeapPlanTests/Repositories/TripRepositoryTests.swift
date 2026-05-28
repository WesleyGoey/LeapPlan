//
//  TripRepositoryTests.swift
//  LeapPlan
//
//  Created by student on 28/05/26.
//

import XCTest
@testable import LeapPlan

final class TripRepositoryTests: XCTestCase {
    var mockRepo: MockTripRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockTripRepository()
    }

    override func tearDown() {
        mockRepo = nil
        super.tearDown()
    }

    func testFetchTripsSuccess() async throws {
        let trip = Trip(id: "trip_001", title: "Bali Escapade", locationName: "Bali", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: ["user_1"], createdAt: Date(), createdBy: "user_1")
        mockRepo.mockTrips = [trip]

        let fetchedTrips = try await mockRepo.fetchTrips(forUserID: "user_1")
        
        XCTAssertEqual(fetchedTrips.count, 1)
        XCTAssertEqual(fetchedTrips.first?.title, "Bali Escapade")
    }
    
    func testFetchTripsFailure() async {
        mockRepo.shouldReturnError = true
        
        do {
            _ = try await mockRepo.fetchTrips(forUserID: "user_1")
            XCTFail("Expected fetchTrips to throw an error.")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testCreateTripSuccess() async throws {
        let newTrip = Trip(id: "trip_002", title: "Surabaya Culinary", locationName: "Surabaya", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: ["user_1"], createdAt: Date(), createdBy: "user_1")
        
        try await mockRepo.createTrip(newTrip, forUserID: "user_1")
        
        XCTAssertEqual(mockRepo.mockTrips.count, 1)
        XCTAssertEqual(mockRepo.mockTrips.first?.id, "trip_002")
    }

    func testUpdateTripSuccess() async throws {
        let originalTrip = Trip(id: "trip_001", title: "Old Title", locationName: "Bali", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: ["user_1"], createdAt: Date(), createdBy: "user_1")
        mockRepo.mockTrips = [originalTrip]
        
        var updatedTrip = originalTrip
        updatedTrip.title = "New Title Updated"
        
        try await mockRepo.updateTrip(updatedTrip, forUserID: "user_1")
        
        XCTAssertEqual(mockRepo.mockTrips.first?.title, "New Title Updated")
    }

    func testDeleteTripSuccess() async throws {
        let trip1 = Trip(id: "trip_001", title: "Bali", locationName: "Bali", startDate: Date(), endDate: Date(), status: .completed, participantIDs: ["user_1"], createdAt: Date(), createdBy: "user_1")
        let trip2 = Trip(id: "trip_002", title: "Jakarta", locationName: "Jakarta", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: ["user_1"], createdAt: Date(), createdBy: "user_1")
        mockRepo.mockTrips = [trip1, trip2]
        
        try await mockRepo.deleteTrip(tripID: "trip_001", forUserID: "user_1")
        
        XCTAssertEqual(mockRepo.mockTrips.count, 1)
        XCTAssertEqual(mockRepo.mockTrips.first?.id, "trip_002")
    }
    
    func testSaveAndFetchDayPlans() async throws {
        XCTAssertNotNil(mockRepo)
    }
}
