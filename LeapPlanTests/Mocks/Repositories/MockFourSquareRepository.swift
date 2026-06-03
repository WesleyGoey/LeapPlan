//
//  MockFourSquareRepository.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Foundation
@testable import LeapPlan

class MockFourSquareRepository: FourSquareRepositoryProtocol {
    // 1. Data yang akan dikembalikan saat test (Stubbing)
    var stubbedPlaces: [FSQPlace] = []
    var stubbedPhotoUrl: String? = nil
    
    // 2. Control untuk simulasi Error
    var shouldThrowError = false
    
    // MARK: - Implementasi Protocol
    
    func searchPlaces(query: String, latitude: Double, longitude: Double) async throws -> [FSQPlace] {
        if shouldThrowError { throw URLError(.badServerResponse) }
        return stubbedPlaces
    }
    
    func fetchPlaces(near city: String, categoryID: String, limit: Int) async throws -> [FSQPlace] {
        if shouldThrowError { throw URLError(.badServerResponse) }
        return stubbedPlaces
    }
    
    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        if shouldThrowError { throw URLError(.badServerResponse) }
        return stubbedPlaces
    }
    
    func searchPlacesByCity(near city: String, query: String, limit: Int) async throws -> [FSQPlace] {
        if shouldThrowError { throw URLError(.badServerResponse) }
        return stubbedPlaces
    }
    
    func fetchPlacePhotos(id: String) async throws -> String? {
        if shouldThrowError { throw URLError(.badServerResponse) }
        return stubbedPhotoUrl
    }
}
