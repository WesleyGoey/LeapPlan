//
//  TripDestinationServiceTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class TripDestinationServiceTests: XCTestCase {
    
    var service: TripDestinationService!
    var mockFirestore: MockFirestoreRepository!
    
    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestoreRepository()
        service = TripDestinationService(firestoreRepo: mockFirestore)
    }
    
    override func tearDown() {
        service = nil
        mockFirestore = nil
        super.tearDown()
    }
    
    func testCalculateTimeline_CorrectFormatting() {
        // Arrange
        let dest1 = TripDestination(id: "1", name: "Destinasi A", category: "Wisata", foursquareID: nil, latitude: 0, longitude: 0, orderIndex: 0, stayDurationMinutes: 60, transitTimeToNextMinutes: 15)
        let dest2 = TripDestination(id: "2", name: "Destinasi B", category: "Wisata", foursquareID: nil, latitude: 0, longitude: 0, orderIndex: 1, stayDurationMinutes: 120, transitTimeToNextMinutes: 30)
        
        // Hari dimulai default jam 09:00 AM di service
        let dayPlan = DayPlan(id: "day_1", dayNumber: 1, date: Date(), destinations: [dest1, dest2])
        
        // Act
        // Destinasi pertama harusnya jam 09:00 AM
        let time1 = service.calculateTimeline(for: dest1, in: dayPlan)
        // Destinasi kedua = 09:00 + 60 mnt stay + 15 mnt transit = 10:15 AM
        let time2 = service.calculateTimeline(for: dest2, in: dayPlan)
        
        // Assert
        XCTAssertEqual(time1, "09:00 AM")
        XCTAssertEqual(time2, "10:15 AM")
    }
    
    func testRemovePlaceFromTrip_Success() async throws {
        // Arrange
        let tripID = "trip_bali_123"
        let userID = "user_sean"
        let fsqPlaceID = "fsq_coffee_shop"
        
        let destination = TripDestination(id: "dest_123", name: "Expat Roasters", category: "Cafe", foursquareID: fsqPlaceID, latitude: -8.1, longitude: 115.1, orderIndex: 0, stayDurationMinutes: 60, transitTimeToNextMinutes: nil)
        let initialPlan = DayPlan(id: "plan_1", dayNumber: 1, date: Date(), destinations: [destination])
        
        mockFirestore.dayPlans[tripID] = [initialPlan]
        
        // Act: Hapus tempat via service toggle
        try await service.removePlaceFromTrip(placeID: fsqPlaceID, tripID: tripID, dayNum: 1, userID: userID)
        
        // Assert: Pastikan destinasi kosong setelah dihapus
        let updatedPlans = try await mockFirestore.fetchDayPlans(forTripID: tripID, userID: userID)
        XCTAssertTrue(updatedPlans.first?.destinations.isEmpty ?? false)
    }
}
