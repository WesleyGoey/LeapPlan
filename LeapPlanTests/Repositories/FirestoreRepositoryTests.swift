//
//  FirestoreRepositoryTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//



import XCTest
import FirebaseFirestore
@testable import LeapPlan

private let configureFirestoreEmulatorOnce: Void = {
     let settings = Firestore.firestore().settings
     settings.host = "localhost:8080"
     settings.isSSLEnabled = false
     Firestore.firestore().settings = settings
 }()

 final class FirestoreRepositoryTests: XCTestCase {
     
     var repository: FirestoreRepository!
     let mockUserID = "testing_uid_123"
     
     override func setUpWithError() throws {
         try super.setUpWithError()
         repository = FirestoreRepository()
         
         // Panggil token eksekusi sekali
         _ = configureFirestoreEmulatorOnce
     }
     
     override func tearDownWithError() throws {
         repository = nil
         try super.tearDownWithError()
     }
    
    func testCreateAndFetchTrip_Success() async throws {
        // Arrange
        let tripID = UUID().uuidString
        let mockTrip = Trip(id: tripID, title: "Trip Liburan Bali", locationName: "Bali", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: [mockUserID], totalPlaces: 0, createdAt: Date(), createdBy: mockUserID)
        
        // Act
        try await repository.createTrip(mockTrip, forUserID: mockUserID)
        let trips = try await repository.fetchTrips(forUserID: mockUserID)
        
        // Assert
        XCTAssertFalse(trips.isEmpty)
        XCTAssertTrue(trips.contains(where: { $0.id == tripID }))
        XCTAssertEqual(trips.first(where: { $0.id == tripID })?.title, "Trip Liburan Bali")
    }
    
    func testSaveGeneratedTripWithDayPlans_BatchWrite_Success() async throws {
        // Arrange
        let tripID = UUID().uuidString
        let mockTrip = Trip(id: tripID, title: "Surabaya Culinary Trip", locationName: "Surabaya", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: [mockUserID], totalPlaces: 0, createdAt: Date(), createdBy: mockUserID)
        
        let destination = TripDestination(id: UUID().uuidString, name: "Ciputra World Surabaya", category: "Objek Wisata", foursquareID: "4b05a544", latitude: -7.2912, longitude: 112.7234, orderIndex: 0, stayDurationMinutes: 120, transitTimeToNextMinutes: 15, imageURL: nil)
        let mockDayPlan = DayPlan(id: UUID().uuidString, dayNumber: 1, date: Date(), destinations: [destination])
        
        // Act: Eksekusi Batch Save
        try await repository.saveGeneratedTripWithDayPlans(trip: mockTrip, dayPlans: [mockDayPlan], userID: mockUserID)
        
        // Ambil data untuk verifikasi
        let fetchedTrips = try await repository.fetchTrips(forUserID: mockUserID)
        let targetTrip = fetchedTrips.first(where: { $0.locationName == "Surabaya" })
        
        XCTAssertNotNil(targetTrip)
        
        if let actualTripID = targetTrip?.id {
            let fetchedDayPlans = try await repository.fetchDayPlans(forTripID: actualTripID, userID: mockUserID)
            // Assert
            XCTAssertEqual(fetchedDayPlans.count, 1)
            XCTAssertEqual(fetchedDayPlans.first?.destinations.first?.name, "Ciputra World Surabaya")
        } else {
            XCTFail("Trip ID gagal digenerate dari batch commit.")
        }
    }
}
