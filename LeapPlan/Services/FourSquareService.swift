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

    // MARK: - Fetch Trending Places
    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace] {
        let places = try await repo.fetchPlaces(
            near: city,
            categoryID: "16000",
            limit: 10
        )
        return places
    }

    // MARK: - Search Places
    func searchPlaces(query: String, latitude: Double, longitude: Double)
        async throws -> [FSQPlace]
    {
        let places = try await repo.searchPlaces(
            query: query,
            latitude: latitude,
            longitude: longitude
        )
        return places
    }

    // MARK: - Fetch Places
    func fetchPlaces(near city: String, categoryID: String, limit: Int)
        async throws -> [FSQPlace]
    {
        let places = try await repo.fetchPlaces(
            near: city,
            categoryID: categoryID,
            limit: limit
        )
        return places
    }

    // MARK: - Autocomplete Location
    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        return try await repo.autocompleteLocation(query: query)
    }

    // MARK: - Search Places By City
    func searchPlacesByCity(near city: String, query: String, limit: Int)
        async throws -> [FSQPlace]
    {
        let places = try await repo.searchPlacesByCity(
            near: city,
            query: query,
            limit: limit
        )
        return places
    }
}
