//
//  ViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//


import XCTest
import Combine
import MapKit
@testable import LeapPlan

@MainActor
final class ViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    // MARK: - HomeViewModel Tests
    func testHomeViewModel_LoadTrending_Success() async {
        let mockService = MockFourSquareService()
        // Menggunakan inisialisasi yang sesuai dengan model aslimu
        mockService.mockPlaces = [FSQPlace(fsq_id: "1", name: "Surabaya Cafe", distance: 150)]
        let viewModel = HomeViewModel(fourSquareService: mockService)
        
        let expectation = XCTestExpectation(description: "Tunggu data trending")
        viewModel.$trendingPlaces.dropFirst().sink { places in
            if !places.isEmpty { expectation.fulfill() }
        }.store(in: &cancellables)

        viewModel.loadTrendingPlaces(for: "Surabaya")
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(viewModel.trendingPlaces.count, 1)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - ProfileViewModel Tests
    func testProfileViewModel_LoadProfile_Success() async {
        let mockUserRepo = MockUserRepository()
        let mockAuth = MockAuthService()
        mockUserRepo.mockUser = User(id: "TEST_USER_123", email: "test@test.com", fullName: "Sean Tandjaja", joinedDate: Date())
        
        let viewModel = ProfileViewModel(userRepository: mockUserRepo, authService: mockAuth)
        let expectation = XCTestExpectation(description: "Tunggu profile ter-load")
        
        viewModel.$currentUser.dropFirst().sink { user in
            if user != nil { expectation.fulfill() }
        }.store(in: &cancellables)

        viewModel.loadProfile()
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(viewModel.currentUser?.fullName, "Sean Tandjaja")
    }

    // MARK: - SearchViewModel Tests
    func testSearchViewModel_PerformSearch() async {
        let mockService = MockFourSquareService()
        mockService.mockPlaces = [FSQPlace(fsq_id: "1", name: "Pakuwon Mall", distance: 50)]
        let viewModel = SearchViewModel(fourSquareService: mockService, locationService: MockLocationService())
        viewModel.searchQuery = "Mall"
        
        let expectation = XCTestExpectation(description: "Tunggu hasil search")
        viewModel.$searchResults.dropFirst().sink { results in
            if !results.isEmpty { expectation.fulfill() }
        }.store(in: &cancellables)

        viewModel.performSearch()
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(viewModel.searchResults.count, 1)
    }

    // MARK: - TripDetailViewModel Tests
    func testTripDetailViewModel_RouteCalculation() {
        // Inisialisasi Trip Dummy
        let dummyTrip = Trip(id: "trip1", title: "Bali Trip", locationName: "Bali", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: [], createdAt: Date(), createdBy: "user123")
        let viewModel = TripDetailViewModel(trip: dummyTrip, tripRepository: MockTripRepository(), authService: MockAuthService())
        
        // Buat dummy destination
        let dest1 = TripDestination(id: "d1", name: "Beach", category: "Nature", latitude: -8.4, longitude: 115.1, orderIndex: 0, stayDurationMinutes: 60)
        let dest2 = TripDestination(id: "d2", name: "Cafe", category: "Cafe", latitude: -8.5, longitude: 115.2, orderIndex: 1, stayDurationMinutes: 60)
        
        viewModel.dayPlans = [DayPlan(id: "day1", dayNumber: 1, date: Date(), destinations: [dest1, dest2])]
        
        viewModel.selectedDayIndex = 0 // Triggers route calculation
        
        XCTAssertNotNil(viewModel.mapRoute)
        XCTAssertEqual(viewModel.mapRoute?.pointCount, 2)
    }

    // MARK: - TripsViewModel Tests
    func testTripsViewModel_CreateManualTrip() async {
        let mockRepo = MockTripRepository()
        let viewModel = TripsViewModel(tripRepository: mockRepo, authService: MockAuthService(), tripGenService: MockTripGenerationService())
        
        let expectation = XCTestExpectation(description: "Tunggu data trip diperbarui")
        viewModel.$trips.dropFirst().sink { _ in expectation.fulfill() }.store(in: &cancellables)

        viewModel.createManualTrip(title: "Japan Trip", location: "Japan", start: Date(), end: Date())
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(mockRepo.mockTrips.count, 1)
        XCTAssertEqual(mockRepo.mockTrips.first?.title, "Japan Trip")
    }
}