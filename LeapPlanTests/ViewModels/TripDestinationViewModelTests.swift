//
//  TripDestinationViewModelTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class TripDestinationViewModelTests: XCTestCase {
    
    private var mockFirestoreRepo: MockFirestoreRepository!
    private var mockAuthService: MockAuthService!
    private var mockTripDestinationService: MockTripDestinationService!
    private var mockFourSquareService: MockFourSquareService!
    private var mockTripService: MockTripService!
    
    private var initialTrip: Trip!
    
    override func setUp() {
        super.setUp()
        mockFirestoreRepo = MockFirestoreRepository()
        mockAuthService = MockAuthService()
        mockTripDestinationService = MockTripDestinationService()
        mockFourSquareService = MockFourSquareService()
        mockTripService = MockTripService()
        
        initialTrip = Trip(id: "bali_trip_id", title: "My Bali Vacation", locationName: "Bali", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: ["user_1"], totalPlaces: 0, createdAt: Date(), createdBy: "user_1")
    }
    
    override func tearDown() {
        mockFirestoreRepo = nil
        mockAuthService = nil
        mockTripDestinationService = nil
        mockFourSquareService = nil
        mockTripService = nil
        initialTrip = nil
        super.tearDown()
    }
    
    @MainActor
    func testLoadDayPlans_Success_SortsByDayNumber() async {
        // Arrange
        let day2 = DayPlan(id: "d2", dayNumber: 2, date: Date(), destinations: [])
        let day1 = DayPlan(id: "d1", dayNumber: 1, date: Date(), destinations: [])
        mockFirestoreRepo.dayPlans["bali_trip_id"] = [day2, day1] // Masukkan tidak berurutan
        
        let viewModel = TripDestinationViewModel(trip: initialTrip, firestoreRepo: mockFirestoreRepo, authService: mockAuthService, tripDestinationService: mockTripDestinationService, fourSquareService: mockFourSquareService, tripService: mockTripService)
        
        // Act
        viewModel.loadDayPlans()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertEqual(viewModel.dayPlans.count, 2)
        XCTAssertEqual(viewModel.dayPlans.first?.dayNumber, 1) // Harus tersortir naik
        XCTAssertEqual(viewModel.dayPlans.last?.dayNumber, 2)
    }
    
    @MainActor
    func testSearchPlacesAroundCity_EnforcesStrictCityFiltering() async {
        // Arrange
        // Buat akomodasi satu kota dasar "Bali" dan satu kota luar "Surabaya"
        let locBali = FSQLocation(locality: "Bali", country: "Indonesia")
        let locSby = FSQLocation(locality: "Surabaya", country: "Indonesia")
        
        let placeInBali = FSQPlace(fsq_place_id: "p_bali", name: "Beach Club Seminyak", distance: nil, latitude: nil, longitude: nil, location: locBali, rating: nil, stats: nil, imageURL: nil)
        let placeInSby = FSQPlace(fsq_place_id: "p_sby", name: "Ciputra World Surabaya", distance: nil, latitude: nil, longitude: nil, location: locSby, rating: nil, stats: nil, imageURL: nil)
        
        mockFourSquareService.stubbedPlaces = [placeInBali, placeInSby]
        
        let viewModel = TripDestinationViewModel(trip: initialTrip, firestoreRepo: mockFirestoreRepo, authService: mockAuthService, tripDestinationService: mockTripDestinationService, fourSquareService: mockFourSquareService, tripService: mockTripService)
        
        // Act
        viewModel.searchPlacesAroundCity(query: "Club")
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        // Ciputra World Surabaya harus dibuang karena Trip saat ini memiliki lokasi kota dasar "Bali"
        XCTAssertEqual(viewModel.addSearchResults.count, 1)
        XCTAssertEqual(viewModel.addSearchResults.first?.fsq_place_id, "p_bali")
    }
}
