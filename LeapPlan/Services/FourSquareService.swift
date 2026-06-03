//
//  FourSquareService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

class FourSquareService: FourSquareServiceProtocol {
    private let repo: FourSquareRepositoryProtocol
    
    init(repo: FourSquareRepositoryProtocol = FourSquareRepository()) {
        self.repo = repo
    }
    
    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace] {
        return try await repo.fetchPlaces(near: city, categoryID: "16000", limit: 10)
    }
    
    func searchPlaces(query: String, latitude: Double, longitude: Double) async throws -> [FSQPlace] {
        return try await repo.searchPlaces(query: query, latitude: latitude, longitude: longitude)
    }
    
    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        return try await repo.autocompleteLocation(query: query)
    }
    
    func fetchPlaces(near city: String, categoryID: String, limit: Int) async throws -> [FSQPlace] {
        return try await repo.fetchPlaces(near: city, categoryID: categoryID, limit: limit)
    }
}
