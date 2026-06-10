//
//  TripDestinationViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import MapKit
import XCTest

@testable import LeapPlan

@MainActor
final class TripDestinationViewModelTests: XCTestCase {

    var viewModel: TripDestinationViewModel!
    var mockFirestoreRepo: MockFirestoreRepository!
    var mockTripDestService: MockTripDestinationService!
    var mockAuthService: MockAuthService!
    var mockFourSquare: MockFourSquareService!

    override func setUp() {
        super.setUp()
        mockFirestoreRepo = MockFirestoreRepository()
        mockTripDestService = MockTripDestinationService()
        mockAuthService = MockAuthService()
        mockFourSquare = MockFourSquareService()

        let trip = Trip(
            id: "t1",
            title: "Bali Trip",
            locationName: "Bali",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 2),
            status: .upcoming,
            participantIDs: [],
            createdAt: Date(),
            createdBy: "u1"
        )

        viewModel = TripDestinationViewModel(
            trip: trip,
            firestoreRepo: mockFirestoreRepo,
            authService: mockAuthService,
            tripDestinationService: mockTripDestService,
            fourSquareService: mockFourSquare
        )
    }

    // MARK: - Test Load Day Plans
    func testLoadDayPlans() async {
        // Arrange
        let day1 = DayPlan(
            id: "p1",
            dayNumber: 1,
            date: Date(),
            destinations: []
        )
        mockFirestoreRepo.mockDayPlans = ["t1": [day1]]

        // Act
        viewModel.loadDayPlans()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        XCTAssertEqual(viewModel.dayPlans.count, 1)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Test Move Destination
    func testMoveDestination() async {
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
        viewModel.dayPlans = [
            DayPlan(id: "p1", dayNumber: 1, date: Date(), destinations: [dest])
        ]

        viewModel.moveDestination(from: IndexSet(integer: 0), to: 1)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockTripDestService.didCallSaveReorder)
    }

    // MARK: - Test Delete Destination
    func testDeleteDestination() async {
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
        viewModel.dayPlans = [
            DayPlan(id: "p1", dayNumber: 1, date: Date(), destinations: [dest])
        ]

        viewModel.deleteDestination(destID: "d1")

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(viewModel.dayPlans[0].destinations.count, 0)
        XCTAssertTrue(mockTripDestService.didCallSaveReorder)
    }

    // MARK: - Test Search Places
    func testSearchPlacesAroundCity() async {
        let place = FSQPlace(
            fsq_place_id: "p1",
            name: "Ubud Monkey Forest",
            distance: 0,
            latitude: 0,
            longitude: 0,
            location: nil
        )
        mockFourSquare.mockPlaces = [place]

        viewModel.searchPlacesAroundCity(query: "Monkey")
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(viewModel.addSearchResults.count, 1)
        XCTAssertEqual(
            viewModel.addSearchResults.first?.name,
            "Ubud Monkey Forest"
        )
    }

    // MARK: - Test Add Manual Destination
    func testAddManualDestination() async {
        viewModel.dayPlans = [
            DayPlan(id: "p1", dayNumber: 1, date: Date(), destinations: [])
        ]

        viewModel.addManualDestination(
            name: "New Place",
            category: "Wisata",
            durationMinutes: 60,
            place: nil
        )

        XCTAssertEqual(viewModel.dayPlans[0].destinations.count, 1)
    }

    // MARK: - Test Update Destination
    func testUpdateDestination() async {
        let dest = TripDestination(
            id: "d1",
            name: "Old",
            category: "A",
            foursquareID: "1",
            latitude: 0,
            longitude: 0,
            orderIndex: 0,
            stayDurationMinutes: 30,
            transitTimeToNextMinutes: 0
        )
        viewModel.dayPlans = [
            DayPlan(id: "p1", dayNumber: 1, date: Date(), destinations: [dest])
        ]

        viewModel.updateDestination(
            id: "d1",
            newName: "New",
            category: "B",
            newDuration: 90,
            place: nil
        )

        XCTAssertEqual(viewModel.dayPlans[0].destinations[0].name, "New")
        XCTAssertEqual(
            viewModel.dayPlans[0].destinations[0].stayDurationMinutes,
            90
        )
    }

    // MARK: - Test Generate Random Place
    func testGenerateOneRandomPlace() async {
        viewModel.dayPlans = [
            DayPlan(id: "p1", dayNumber: 1, date: Date(), destinations: [])
        ]
        mockFourSquare.mockPlaces = [
            FSQPlace(
                fsq_place_id: "r1",
                name: "Random",
                distance: 0,
                latitude: 0,
            longitude: 0,
            location: nil
            )
        ]

        viewModel.generateOneRandomPlace()
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(viewModel.dayPlans[0].destinations.count, 1)
        XCTAssertEqual(viewModel.dayPlans[0].destinations.first?.name, "Random")
    }

    // MARK: - Test Delete Trip
    func testDeleteThisTrip() async {
        let success = await viewModel.deleteThisTrip()

        XCTAssertTrue(success)
        XCTAssertTrue(mockFirestoreRepo.didCallDeleteTrip)
    }
}
