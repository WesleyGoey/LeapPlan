//
//  HomeViewModelTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class HomeViewModelTests: XCTestCase {
    
    private var mockFourSquareService: MockFourSquareService!
    private var mockFirestoreRepo: MockFirestoreRepository!
    private var mockAuthService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        mockFourSquareService = MockFourSquareService()
        mockFirestoreRepo = MockFirestoreRepository()
        mockAuthService = MockAuthService()
    }
    
    override func tearDown() {
        mockFourSquareService = nil
        mockFirestoreRepo = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    @MainActor
    func testLoadDashboardData_UserLoggedIn_Success() async {
        // Arrange
        mockAuthService.stubbedUserID = "user_sean_123"
        
        let dummyPlace = FSQPlace(fsq_place_id: "p_1", name: "Ciputra World", distance: nil, latitude: nil, longitude: nil, location: nil, rating: nil, stats: nil, imageURL: nil)
        mockFourSquareService.stubbedPlaces = [dummyPlace]
        
        let dummyTrip = Trip(id: "t_1", title: "Bali Trip", locationName: "Bali", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: ["user_sean_123"], totalPlaces: 0, createdAt: Date(), createdBy: "user_sean_123")
        mockFirestoreRepo.trips["user_sean_123"] = [dummyTrip]
        
        let viewModel = HomeViewModel(fourSquareService: mockFourSquareService, firestoreRepo: mockFirestoreRepo, authService: mockAuthService)
        
        // Act
        await viewModel.loadDashboardData()
        
        // Assert
        XCTAssertEqual(viewModel.trendingPlaces.count, 1)
        XCTAssertEqual(viewModel.trendingPlaces.first?.name, "Ciputra World")
        XCTAssertNotNil(viewModel.recentTrip)
        XCTAssertEqual(viewModel.recentTrip?.title, "Bali Trip")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testLoadDashboardData_Failure_SetsErrorMessage() async {
        // Arrange
        mockFourSquareService.shouldReturnError = true
        let viewModel = HomeViewModel(fourSquareService: mockFourSquareService, firestoreRepo: mockFirestoreRepo, authService: mockAuthService)
        
        // Act
        await viewModel.loadDashboardData()
        
        // Assert
        XCTAssertTrue(viewModel.trendingPlaces.isEmpty)
        XCTAssertNil(viewModel.recentTrip)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}
