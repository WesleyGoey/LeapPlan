//
//  TripDestinationViewModelTests.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import XCTest
@testable import LeapPlan

@MainActor
final class TripDestinationViewModelTests: XCTestCase {
    var sut: TripDestinationViewModel!
    var mockTripDestinationService: MockTripDestinationService!
    var mockFirestoreRepo: MockTripRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockTripDestinationService = MockTripDestinationService()
        mockFirestoreRepo = MockTripRepository()
        
        // Asumsi inisialisasi memerlukan trip dummy dan dependency service
        let dummyTrip = Trip(title: "Test", locationName: "Sby", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: [], createdAt: Date(), createdBy: "123")
        sut = TripDestinationViewModel(
            trip: dummyTrip,
            tripDestinationService: mockTripDestinationService,
            firestoreRepo: mockFirestoreRepo
        )
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockTripDestinationService = nil
        mockFirestoreRepo = nil
        try super.tearDownWithError()
    }
    
    func test_addDestination_whenSuccess_shouldTriggerService() async {
        // Given
        let dummyPlace = FSQResponse(name: "Tunjungan Plaza")
        mockTripDestinationService.shouldThrowError = false
        
        // When
        // sut.addPlace(dummyPlace, forDay: 1) // Sesuaikan dengan nama fungsi aslimu
        
        // Then
        // XCTAssertTrue(mockTripDestinationService.didCallAddPlace)
    }
}