//
//  TripServiceTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class TripServiceTests: XCTestCase {
    
    var service: TripService!
    var mockFourSquare: MockFourSquareService!
    var mockFirestore: MockFirestoreRepository!
    
    override func setUp() {
        super.setUp()
        mockFourSquare = MockFourSquareService()
        mockFirestore = MockFirestoreRepository()
        service = TripService(foursquareService: mockFourSquare, firestoreRepo: mockFirestore)
    }
    
    override func tearDown() {
        service = nil
        mockFourSquare = nil
        mockFirestore = nil
        super.tearDown()
    }
    
    func testGenerateRandomItinerary_FiltersInvalidPlaces() async throws {
        // Arrange
        let place1 = FSQPlace(fsq_place_id: "id_wisata", name: "Tanah Lot Bali", distance: nil, latitude: -8.1, longitude: 115.0, location: nil, rating: nil, stats: nil)
        let place2 = FSQPlace(fsq_place_id: "id_atm", name: "ATM Bank BCA Seminyak", distance: nil, latitude: -8.2, longitude: 115.1, location: nil, rating: nil, stats: nil) // Harusnya terfilter keluar
        
        mockFourSquare.stubbedPlaces = [place1, place2]
        
        let prefs = RandomTripPreferences(
            locationName: "Bali",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            dailyPreferences: [DailyPreference(dayNumber: 1, meals: 3, places: 2)]
        )
        
        // Act
        let generatedPlans = try await service.generateRandomItinerary(preferences: prefs)
        
        // Assert
        XCTAssertEqual(generatedPlans.count, 1)
        let destinations = generatedPlans.first?.destinations ?? []
        
        // Pastikan objek wisata masuk, dan ATM Bank BCA tereliminasi oleh keyword filtering
        XCTAssertTrue(destinations.contains(where: { $0.name == "Tanah Lot Bali" }))
        XCTAssertFalse(destinations.contains(where: { $0.name.contains("ATM") }))
    }
}
