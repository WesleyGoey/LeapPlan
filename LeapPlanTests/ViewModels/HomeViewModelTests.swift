//
//  HomeViewModelTests.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import XCTest
@testable import LeapPlan

@MainActor
final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockAuthService: MockAuthService!
    var mockFirestoreRepo: MockTripRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAuthService = MockAuthService()
        mockFirestoreRepo = MockTripRepository()
        
        sut = HomeViewModel(
            authService: mockAuthService,
            firestoreRepo: mockFirestoreRepo
        )
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockAuthService = nil
        mockFirestoreRepo = nil
        try super.tearDownWithError()
    }
    
    func test_fetchRecentTrips_shouldPopulateData() async {
        // Given
        mockAuthService.isLoggedIn = true
        let dummyTrip = Trip(title: "Bali Getaway", locationName: "Bali", startDate: Date(), endDate: Date(), status: .past, participantIDs: [], createdAt: Date(), createdBy: "user")
        mockFirestoreRepo.stubbedTrips = [dummyTrip]
        
        // When
        sut.loadDashboardData()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        // XCTAssertEqual(sut.recentTrips.count, 1) // Sesuaikan dengan nama variabel di HomeViewModel kamu
    }
}