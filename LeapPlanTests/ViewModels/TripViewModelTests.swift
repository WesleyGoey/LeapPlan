//
//  TripViewModelTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class TripViewModelTests: XCTestCase {
    
    private var mockFirestoreRepo: MockFirestoreRepository!
    private var mockAuthService: MockAuthService!
    private var mockTripService: MockTripService!
    private var mockFourSquareService: MockFourSquareService!
    private var mockTripDestinationService: MockTripDestinationService!
    
    override func setUp() {
        super.setUp()
        mockFirestoreRepo = MockFirestoreRepository()
        mockAuthService = MockAuthService()
        mockTripService = MockTripService()
        mockFourSquareService = MockFourSquareService()
        mockTripDestinationService = MockTripDestinationService()
    }
    
    override func tearDown() {
        mockFirestoreRepo = nil
        mockAuthService = nil
        mockTripService = nil
        mockFourSquareService = nil
        mockTripDestinationService = nil
        super.tearDown()
    }
    
    @MainActor
    func testCreateManualTrip_Success_SavesAndReloads() async throws {
        // Arrange
        mockAuthService = MockAuthService()
        mockAuthService.isLoggedIn = true
        mockAuthService.stubbedUserID = "sean_user_id"
        
        let viewModel = TripViewModel(firestoreRepo: mockFirestoreRepo, authService: mockAuthService, tripService: mockTripService, fourSquareService: mockFourSquareService, tripDestinationService: mockTripDestinationService)
        
        viewModel.destinationForm = "Yogyakarta"
        viewModel.tripNameForm = "Gudeg Hunting"
        viewModel.startDateForm = Date()
        viewModel.endDateForm = Calendar.current.date(byAdding: .day, value: 1, to: Date())! // 2 Hari rencana perjalanan
        
        // Act
        let createdTrip = try await viewModel.createManualTrip()
        
        // Assert
        XCTAssertEqual(createdTrip.title, "Gudeg Hunting")
        XCTAssertEqual(createdTrip.locationName, "Yogyakarta")
        
        // Memastikan daftar trip milik user memuat trip baru tersebut
        XCTAssertEqual(viewModel.trips.count, 1)
        XCTAssertEqual(viewModel.trips.first?.title, "Gudeg Hunting")
    }
    
    @MainActor
    func testTogglePlaceInDay_CallsCorrectServiceMethod() async {
        // Arrange
        let viewModel = TripViewModel(firestoreRepo: mockFirestoreRepo, authService: mockAuthService, tripService: mockTripService, fourSquareService: mockFourSquareService, tripDestinationService: mockTripDestinationService)
        
        let place = FSQPlace(fsq_place_id: "fsq_cafe", name: "Monopole Coffee Lab", distance: nil, latitude: nil, longitude: nil, location: nil, rating: nil, stats: nil, imageURL: nil)
        let trip = Trip(id: "t_1", title: "Sby Trip", locationName: "Surabaya", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: [], createdAt: Date(), createdBy: "user")
        
        // Act: Simulasikan mencentang hari (isAdding = true)
        await viewModel.togglePlaceInDay(place: place, trip: trip, dayNum: 1, isAdding: true)
        // Assert
        XCTAssertTrue(mockTripDestinationService.didCallAddPlace)
        
        // Act: Simulasikan uncheck hari (isAdding = false)
        await viewModel.togglePlaceInDay(place: place, trip: trip, dayNum: 1, isAdding: false)
        // Assert
        XCTAssertTrue(mockTripDestinationService.didCallRemovePlace)
    }
}
