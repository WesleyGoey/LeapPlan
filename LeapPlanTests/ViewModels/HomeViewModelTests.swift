//
//  HomeViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import XCTest

@testable import LeapPlan

@MainActor
final class HomeViewModelTests: XCTestCase {

    var viewModel: HomeViewModel!
    var mockFourSquareService: MockFourSquareService!
    var mockFirestoreRepo: MockFirestoreRepository!
    var mockAuthService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockFourSquareService = MockFourSquareService()
        mockFirestoreRepo = MockFirestoreRepository()
        mockAuthService = MockAuthService()

        viewModel = HomeViewModel(
            fourSquareService: mockFourSquareService,
            firestoreRepo: mockFirestoreRepo,
            authService: mockAuthService
        )
    }

    override func tearDown() {
        viewModel = nil
        mockFourSquareService = nil
        mockFirestoreRepo = nil
        mockAuthService = nil
        super.tearDown()
    }

    // MARK: - Test Load Dashboard Data
    func testLoadDashboardData() async {
        mockAuthService.currentUserIDToReturn = "user_123"

        let tripID = "trip_abc"
        let dummyTrip = Trip(
            id: tripID,
            title: "Liburan Bali",
            locationName: "Bali",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            status: .upcoming,
            participantIDs: ["user_123"],
            createdAt: Date(),
            createdBy: "user_123"
        )
        mockFirestoreRepo.mockTrips = ["user_123": [dummyTrip]]

        let dayPlan = DayPlan(
            id: "plan1",
            dayNumber: 1,
            date: Date(),
            destinations: [
                TripDestination(
                    id: "d1",
                    name: "Pantai",
                    category: "Wisata",
                    foursquareID: "fsq1",
                    latitude: 0,
                    longitude: 0,
                    orderIndex: 0,
                    stayDurationMinutes: 60,
                    transitTimeToNextMinutes: 0
                )
            ]
        )
        mockFirestoreRepo.mockDayPlans = [tripID: [dayPlan]]

        mockFourSquareService.mockPlaces = [
            FSQPlace(
                fsq_place_id: "p1",
                name: "Cafe Hits",
                distance: 100,
                latitude: 0,
                longitude: 0,
                location: nil,
                rating: 5.0,
                stats: nil
            )
        ]

        await viewModel.loadDashboardData()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.trendingPlaces.count, 1)
        XCTAssertEqual(viewModel.recentTrip?.title, "Liburan Bali")
        XCTAssertEqual(viewModel.recentTripPlacesCount, 1)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Test Load Dashboard Data in Guest Mode
    func testLoadDashboardData_GuestMode() async {
        mockAuthService.currentUserIDToReturn = nil
        mockFourSquareService.mockPlaces = [
            FSQPlace(
                fsq_place_id: "p1",
                name: "Beach",
                distance: 0,
                latitude: 0,
                longitude: 0,
                location: nil,
                rating: 5,
                stats: nil
            )
        ]

        await viewModel.loadDashboardData()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.trendingPlaces.count, 1)
        XCTAssertNil(
            viewModel.recentTrip,
            "Recent trip harus nil jika user tidak login"
        )
        XCTAssertEqual(viewModel.recentTripPlacesCount, 0)
    }

    // MARK: - Test Load Dashboard Data Error Handling
    func testLoadDashboardData_ErrorHandling() async {
        mockFourSquareService.shouldThrowError = true

        await viewModel.loadDashboardData()

        XCTAssertNotNil(
            viewModel.errorMessage,
            "Error message harus muncul jika API gagal"
        )
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Test Load Dashboard Data Filters Upcoming Trips
    func testLoadDashboardData_filtersUpcomingTrips() async {
        mockAuthService.currentUserIDToReturn = "user_123"

        let pastTrip = Trip(
            id: "past",
            title: "Past",
            locationName: "X",
            startDate: Date().addingTimeInterval(-86400),
            endDate: Date(),
            status: .past,
            participantIDs: [],
            createdAt: Date(),
            createdBy: "u1"
        )
        let upcomingTrip = Trip(
            id: "upcoming",
            title: "Upcoming",
            locationName: "Y",
            startDate: Date().addingTimeInterval(86400),
            endDate: Date().addingTimeInterval(172800),
            status: .upcoming,
            participantIDs: [],
            createdAt: Date(),
            createdBy: "u1"
        )

        mockFirestoreRepo.mockTrips = ["user_123": [pastTrip, upcomingTrip]]

        await viewModel.loadDashboardData()

        XCTAssertEqual(
            viewModel.recentTrip?.id,
            "upcoming",
            "ViewModel harus menampilkan trip mendatang, bukan yang sudah lewat"
        )
    }
}
