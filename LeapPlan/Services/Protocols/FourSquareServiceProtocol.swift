//
//  FourSquareServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

protocol FourSquareServiceProtocol {
    // MARK: - Fetch Trending Places
    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace]
    // MARK: - Search Places
    func searchPlaces(query: String, latitude: Double, longitude: Double)
        async throws -> [FSQPlace]
    // MARK: - Autocomplete Location
    func autocompleteLocation(query: String) async throws -> [FSQPlace]
    // MARK: - Fetch Places
    func fetchPlaces(near city: String, categoryID: String, limit: Int)
        async throws -> [FSQPlace]

    // MARK: - Search Places By City
    func searchPlacesByCity(near city: String, query: String, limit: Int)
        async throws -> [FSQPlace]
}
