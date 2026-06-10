//
//  TripViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import XCTest

@testable import LeapPlan

@MainActor
final class TripViewModelTests: XCTestCase {

    var viewModel: TripViewModel!
    var mockFirestoreRepo: MockFirestoreRepository!
    var mockAuthService: MockAuthService!
    var mockTripService: MockTripService!
    var mockFourSquare: MockFourSquareService!
    var mockTripDestService: MockTripDestinationService!

    override func setUp() {
        super.setUp()
        mockFirestoreRepo = MockFirestoreRepository()
        mockAuthService = MockAuthService()
        mockTripService = MockTripService()
        mockFourSquare = MockFourSquareService()
        mockTripDestService = MockTripDestinationService()

        viewModel = TripViewModel(
            firestoreRepo: mockFirestoreRepo,
            authService: mockAuthService,
            tripService: mockTripService,
            fourSquareService: mockFourSquare,
            tripDestinationService: mockTripDestService
        )
    }

    override func tearDown() {
        viewModel = nil
        mockFirestoreRepo = nil
        mockAuthService = nil
        mockTripService = nil
        mockFourSquare = nil
        mockTripDestService = nil
        super.tearDown()
    }

    // MARK: - Test Load User Trips
    func testLoadUserTrips() async {
        mockAuthService.isLoggedIn = true
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
        mockFirestoreRepo.mockTrips = ["user_123": [trip]]

        viewModel.loadUserTrips()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(viewModel.trips.count, 1)
        XCTAssertTrue(mockFirestoreRepo.didCallFetchTrips)
    }

    // MARK: - Test Delete Trip
    func testDeleteTrip() async {
        viewModel.deleteTrip(tripID: "t1")
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockFirestoreRepo.didCallDeleteTrip)
    }

    // MARK: - Test Generate Random Trip
    func testGenerateRandomTrip() async throws {
        viewModel.destinationForm = "Bali"
        let dayPlan = DayPlan(
            id: "p1",
            dayNumber: 1,
            date: Date(),
            destinations: []
        )
        mockTripService.mockDayPlans = [dayPlan]

        _ = try await viewModel.generateRandomTrip()

        XCTAssertTrue(mockTripService.didCallGenerate)
        XCTAssertTrue(mockFirestoreRepo.didCallSaveGeneratedTrip)
    }

    // MARK: - Test Toggle Place in Day
    func testTogglePlaceInDay() async {
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
            fsq_place_id: "p1",
            name: "Beach",
            distance: 0,
            latitude: 0,
            longitude: 0,
            location: nil
        )

        await viewModel.togglePlaceInDay(
            place: place,
            trip: trip,
            dayNum: 1,
            isAdding: true
        )

        XCTAssertTrue(mockTripDestService.didCallAddPlace)

        await viewModel.togglePlaceInDay(
            place: place,
            trip: trip,
            dayNum: 1,
            isAdding: false
        )

        XCTAssertTrue(mockTripDestService.didCallRemovePlace)
    }

    // MARK: - Test Create Manual Trip
    func testCreateManualTrip_SavesTrip() async throws {
        viewModel.destinationForm = "Bali"

        _ = try await viewModel.createManualTrip()

        XCTAssertTrue(mockFirestoreRepo.didCallSaveGeneratedTrip)
    }
}
