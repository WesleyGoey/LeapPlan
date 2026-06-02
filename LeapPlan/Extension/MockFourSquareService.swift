//
//  MockFourSquareService.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import Foundation

@testable import LeapPlan  // Wajib agar bisa membaca file dari target utama LeapPlan

class MockFourSquareService: FourSquareServiceProtocol {
    var shouldReturnError = false
    var mockPlaces: [FSQPlace] = []

    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace] {
        if shouldReturnError { throw URLError(.badServerResponse) }
        return mockPlaces
    }

    func searchPlaces(query: String, latitude: Double, longitude: Double)
        async throws -> [FSQPlace]
    {
        if shouldReturnError { throw URLError(.badServerResponse) }
        return mockPlaces
    }

    // MARK: - BARU: Fungsi Autocomplete & Fetch berdasarkan Kota
    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        if shouldReturnError { throw URLError(.badServerResponse) }
        
        // PERBAIKAN: Masukkan angka 0 untuk distance, bukan tulisan "Int" atau "Int?"
        return [FSQPlace(fsq_place_id: UUID().uuidString, name: query + " City", distance: 0, latitude: 0.0, longitude: 0.0)]
    }

    func fetchPlaces(near city: String, categoryID: String, limit: Int)
        async throws -> [FSQPlace]
    {
        if shouldReturnError { throw URLError(.badServerResponse) }
        return mockPlaces
    }
}
