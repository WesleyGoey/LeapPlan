//
//  TripsViewModelTests.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import XCTest
import Combine
@testable import LeapPlan

@MainActor // Tambahkan MainActor karena TripViewModel diisolasi di Main Thread
final class TripsViewModelTests: XCTestCase {

    // SUT (System Under Test)
    var sut: TripViewModel!
    
    // Mocks
    var mockFirestoreRepo: MockTripRepository!
    var mockAuthService: MockAuthService!
    var mockFourSquareService: MockFourSquareService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // 1. Inisialisasi Mocks
        mockFirestoreRepo = MockTripRepository()
        mockAuthService = MockAuthService()
        mockFourSquareService = MockFourSquareService()
        
        // 2. Inject Mocks ke SUT (ViewModel)
        sut = TripViewModel(
            firestoreRepo: mockFirestoreRepo,
            authService: mockAuthService,
            tripService: nil, // Bisa diisi MockTripGenerationService nanti
            fourSquareService: mockFourSquareService,
            tripDestinationService: nil
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        mockFirestoreRepo = nil
        mockAuthService = nil
        mockFourSquareService = nil
        try super.tearDownWithError()
    }

    // MARK: - TEST CASES
    
    func test_resetForm_shouldClearAllState() {
        // Given (Kondisi Awal)
        sut.destinationForm = "Bali"
        sut.tripNameForm = "Liburan Musim Panas"
        sut.autocompleteResults = ["Bali", "Balikpapan"]
        sut.isShowingDropdown = true
        
        // When (Aksi)
        sut.resetForm()
        
        // Then (Ekspektasi)
        XCTAssertEqual(sut.destinationForm, "")
        XCTAssertEqual(sut.tripNameForm, "")
        XCTAssertTrue(sut.autocompleteResults.isEmpty)
        XCTAssertFalse(sut.isShowingDropdown)
    }
    
    func test_loadUserTrips_whenSuccess_shouldPopulateTrips() async {
        // Given
        let dummyTrip = Trip(title: "Dummy Trip", locationName: "Tokyo", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: ["test_user_123"], createdAt: Date(), createdBy: "test_user_123")
        mockFirestoreRepo.stubbedTrips = [dummyTrip]
        mockAuthService.isLoggedIn = true
        
        // When
        sut.loadUserTrips()
        
        // Beri jeda sangat kecil agar Task async selesai dieksekusi di background
        try? await Task.sleep(nanoseconds: 100_000_000) 
        
        // Then
        XCTAssertTrue(mockFirestoreRepo.didCallFetchTrips)
        XCTAssertEqual(sut.trips.count, 1)
        XCTAssertEqual(sut.trips.first?.title, "Dummy Trip")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_deleteTrip_shouldCallDeleteOnRepositoryAndReload() async {
        // Given
        let tripIDToDelete = "trip_999"
        
        // When
        sut.deleteTrip(tripID: tripIDToDelete)
        
        // Wait for async task to finish
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(mockFirestoreRepo.didCallDeleteTrip)
        XCTAssertEqual(mockFirestoreRepo.deletedTripID, tripIDToDelete)
        XCTAssertTrue(mockFirestoreRepo.didCallFetchTrips, "Should reload trips after deletion")
    }
}