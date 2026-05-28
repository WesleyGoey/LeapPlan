//
//  TripGenerationServiceTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import XCTest
@testable import LeapPlan

final class TripGenerationServiceTests: XCTestCase {
    
    var service: TripGenerationService!
    
    override func setUp() {
        super.setUp()
        service = TripGenerationService()
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Test Case 1: Akurasi Jumlah Hari (Multi-Day Trip)
    func testGenerateRandomItinerary_CreatesCorrectNumberOfDays() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 2, to: startDate)!
        
        let preferences = RandomTripPreferences(
            locationName: "Tokyo",
            startDate: startDate,
            endDate: endDate,
            mealsPerDay: 3,
            placesToVisitPerDay: 2
        )
        
        let generatedItinerary = service.generateRandomItinerary(preferences: preferences)
        
        XCTAssertEqual(generatedItinerary.count, 3, "Algoritma harus menghasilkan array DayPlan sebanyak 3 hari.")
        
        XCTAssertEqual(generatedItinerary[0].dayNumber, 1, "Hari pertama harus berlabel Day 1")
        XCTAssertEqual(generatedItinerary[1].dayNumber, 2, "Hari kedua harus berlabel Day 2")
        XCTAssertEqual(generatedItinerary[2].dayNumber, 3, "Hari ketiga harus berlabel Day 3")
    }
    
    // MARK: - Test Case 2: Akurasi Jumlah Destinasi Per Hari
    func testGenerateRandomItinerary_CreatesCorrectNumberOfDestinationsPerDay() {
        let today = Date()
        let preferences = RandomTripPreferences(
            locationName: "Bali",
            startDate: today,
            endDate: today,
            mealsPerDay: 2,
            placesToVisitPerDay: 4
        )
        
        let generatedItinerary = service.generateRandomItinerary(preferences: preferences)
        
        XCTAssertEqual(generatedItinerary.count, 1, "Hanya boleh ada 1 hari di itinerary")
        
        let dayPlan = generatedItinerary.first!
        let expectedTotalActivities = preferences.mealsPerDay + preferences.placesToVisitPerDay
        
        XCTAssertEqual(dayPlan.destinations.count, expectedTotalActivities, "Total destinasi di hari itu harus tepat berjumlah 6 aktivitas.")
        
        XCTAssertEqual(dayPlan.destinations[0].category, "Tempat Makan", "Destinasi pertama harus Tempat Makan")
        XCTAssertEqual(dayPlan.destinations[1].category, "Objek Wisata", "Destinasi kedua harus Objek Wisata")
    }
    
    // MARK: - Test Case 3: Logika Urutan (Order Index) Tidak Boleh Tertukar
    func testGenerateRandomItinerary_AssignsCorrectOrderIndex() {
        let today = Date()
        let preferences = RandomTripPreferences(
            locationName: "Seoul",
            startDate: today,
            endDate: today,
            mealsPerDay: 2,
            placesToVisitPerDay: 2
        )
        
        let generatedItinerary = service.generateRandomItinerary(preferences: preferences)
        let dayPlan = generatedItinerary.first!
        
        for (expectedIndex, destination) in dayPlan.destinations.enumerated() {
            XCTAssertEqual(destination.orderIndex, expectedIndex, "Order Index di destinasi gagal ter-set dengan benar. Expected: \(expectedIndex), Got: \(destination.orderIndex)")
        }
    }
}
