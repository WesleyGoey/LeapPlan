//
//  TripGenerationServiceTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import XCTest
@testable import LeapPlan // Mengakses target utama aplikasimu

final class TripGenerationServiceTests: XCTestCase {
    
    // System Under Test (SUT)
    var service: TripGenerationService!
    
    // Dijalankan secara otomatis SEBELUM setiap fungsi test dieksekusi
    override func setUp() {
        super.setUp()
        service = TripGenerationService()
    }
    
    // Dijalankan secara otomatis SETELAH setiap fungsi test selesai
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Test Case 1: Akurasi Jumlah Hari (Multi-Day Trip)
    func testGenerateRandomItinerary_CreatesCorrectNumberOfDays() {
        // 1. GIVEN (Kondisi Awal / Input)
        let startDate = Date()
        // Kita set End Date menjadi 2 hari setelah Start Date (Total durasi liburan: 3 hari)
        let endDate = Calendar.current.date(byAdding: .day, value: 2, to: startDate)!
        
        let preferences = RandomTripPreferences(
            locationName: "Tokyo",
            startDate: startDate,
            endDate: endDate,
            mealsPerDay: 3,         // 3 kali makan
            placesToVisitPerDay: 2  // 2 tempat wisata
        )
        
        // 2. WHEN (Aksi yang diuji)
        let generatedItinerary = service.generateRandomItinerary(preferences: preferences)
        
        // 3. THEN (Validasi Hasil)
        XCTAssertEqual(generatedItinerary.count, 3, "Algoritma harus menghasilkan array DayPlan sebanyak 3 hari.")
        
        // Validasi urutan penomoran hari
        XCTAssertEqual(generatedItinerary[0].dayNumber, 1, "Hari pertama harus berlabel Day 1")
        XCTAssertEqual(generatedItinerary[1].dayNumber, 2, "Hari kedua harus berlabel Day 2")
        XCTAssertEqual(generatedItinerary[2].dayNumber, 3, "Hari ketiga harus berlabel Day 3")
    }
    
    // MARK: - Test Case 2: Akurasi Jumlah Destinasi Per Hari
    func testGenerateRandomItinerary_CreatesCorrectNumberOfDestinationsPerDay() {
        // 1. GIVEN
        let today = Date()
        let preferences = RandomTripPreferences(
            locationName: "Bali",
            startDate: today,
            endDate: today, // Liburan cuma 1 hari (pulang-pergi)
            mealsPerDay: 2,
            placesToVisitPerDay: 4
        )
        
        // 2. WHEN
        let generatedItinerary = service.generateRandomItinerary(preferences: preferences)
        
        // 3. THEN
        XCTAssertEqual(generatedItinerary.count, 1, "Hanya boleh ada 1 hari di itinerary")
        
        let dayPlan = generatedItinerary.first!
        let expectedTotalActivities = preferences.mealsPerDay + preferences.placesToVisitPerDay // 2 + 4 = 6
        
        XCTAssertEqual(dayPlan.destinations.count, expectedTotalActivities, "Total destinasi di hari itu harus tepat berjumlah 6 aktivitas.")
        
        // Validasi pembagian kategori (berdasarkan logika modulu % 2 di service-mu)
        // Order genap = Makan, Order ganjil = Wisata
        XCTAssertEqual(dayPlan.destinations[0].category, "Tempat Makan", "Destinasi pertama harus Tempat Makan")
        XCTAssertEqual(dayPlan.destinations[1].category, "Objek Wisata", "Destinasi kedua harus Objek Wisata")
    }
    
    // MARK: - Test Case 3: Logika Urutan (Order Index) Tidak Boleh Tertukar
    func testGenerateRandomItinerary_AssignsCorrectOrderIndex() {
        // 1. GIVEN
        let today = Date()
        let preferences = RandomTripPreferences(
            locationName: "