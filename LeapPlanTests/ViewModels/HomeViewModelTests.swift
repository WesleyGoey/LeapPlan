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
    
    // MARK: - Test Cases
    
    func testLoadDashboardData_Success_WhenLoggedIn() async {
        // Arrange
        mockAuthService.currentUserIDToReturn = "user_123"
        
        // Mock Trip
        let tripID = "trip_abc"
        let dummyTrip = Trip(id: tripID, title: "Liburan Bali", locationName: "Bali", startDate: Date(), endDate: Date().addingTimeInterval(86400), status: .upcoming, participantIDs: ["user_123"], createdAt: Date(), createdBy: "user_123")
        mockFirestoreRepo.mockTrips = ["user_123": [dummyTrip]]
        
        // Mock DayPlans (untuk hitung count)
        let dayPlan = DayPlan(id: "plan1", dayNumber: 1, date: Date(), destinations: [
            TripDestination(id: "d1", name: "Pantai", category: "Wisata", foursquareID: "fsq1", latitude: 0, longitude: 0, orderIndex: 0, stayDurationMinutes: 60, transitTimeToNextMinutes: 0)
        ])
        mockFirestoreRepo.mockDayPlans = [tripID: [dayPlan]]
        
        // Mock Trending Places
        mockFourSquareService.mockPlaces = [FSQPlace(fsq_place_id: "p1", name: "Cafe Hits", distance: 100, latitude: 0, longitude: 0, location: nil, rating: 5.0, stats: nil)]
        
        // Act
        await viewModel.loadDashboardData()
        
        // Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.trendingPlaces.count, 1)
        XCTAssertEqual(viewModel.recentTrip?.title, "Liburan Bali")
        XCTAssertEqual(viewModel.recentTripPlacesCount, 1)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadDashboardData_GuestMode() async {
        // Arrange: User tidak login
        mockAuthService.currentUserIDToReturn = nil
        mockFourSquareService.mockPlaces = [FSQPlace(fsq_place_id: "p1", name: "Beach", distance: 0, latitude: 0, longitude: 0, location: nil, rating: 5, stats: nil)]
        
        // Act
        await viewModel.loadDashboardData()
        
        // Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.trendingPlaces.count, 1)
        XCTAssertNil(viewModel.recentTrip, "Recent trip harus nil jika user tidak login")
        XCTAssertEqual(viewModel.recentTripPlacesCount, 0)
    }
    
    func testLoadDashboardData_HandlesError() async {
        // Arrange: Service throw error
        mockFourSquareService.shouldThrowError = true
        
        // Act
        await viewModel.loadDashboardData()
        
        // Assert
        XCTAssertNotNil(viewModel.errorMessage, "Error message harus muncul jika API gagal")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadDashboardData_FiltersUpcomingTripsOnly() async {
        // Arrange: User login dengan 2 trip (Past & Upcoming)
        mockAuthService.currentUserIDToReturn = "user_123"
        
        let pastTrip = Trip(id: "past", title: "Past", locationName: "X", startDate: Date().addingTimeInterval(-86400), endDate: Date(), status: .past, participantIDs: [], createdAt: Date(), createdBy: "u1")
        let upcomingTrip = Trip(id: "upcoming", title: "Upcoming", locationName: "Y", startDate: Date().addingTimeInterval(86400), endDate: Date().addingTimeInterval(172800), status: .upcoming, participantIDs: [], createdAt: Date(), createdBy: "u1")
        
        mockFirestoreRepo.mockTrips = ["user_123": [pastTrip, upcomingTrip]]
        
        // Act
        await viewModel.loadDashboardData()
        
        // Assert: ViewModel harus memilih trip yang upcoming
        XCTAssertEqual(viewModel.recentTrip?.id, "upcoming", "ViewModel harus menampilkan trip mendatang, bukan yang sudah lewat")
    }
}
