//
//  MockFourSquareService.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Foundation
@testable import LeapPlan

class MockFourSquareService: FourSquareServiceProtocol {
    var stubbedPlaces: [FSQPlace] = []
    var shouldReturnError = false
    
    var didCallFetchTrending = false
    var didCallSearchPlaces = false
    var didCallAutocomplete = false
    var didCallSearchPlacesByCity = false

    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace] {
        didCallFetchTrending = true
        if shouldReturnError { throw URLError(.notConnectedToInternet) }
        return stubbedPlaces
    }
    
    func searchPlaces(query: String, latitude: Double, longitude: Double) async throws -> [FSQPlace] {
        didCallSearchPlaces = true
        if shouldReturnError { throw URLError(.notConnectedToInternet) }
        return stubbedPlaces
    }
    
    func fetchPlaces(near city: String, categoryID: String, limit: Int) async throws -> [FSQPlace] {
        if shouldReturnError { throw URLError(.notConnectedToInternet) }
        return stubbedPlaces
    }
    
    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        didCallAutocomplete = true
        if shouldReturnError { throw URLError(.notConnectedToInternet) }
        return stubbedPlaces
    }
    
    func searchPlacesByCity(near city: String, query: String, limit: Int) async throws -> [FSQPlace] {
        didCallSearchPlacesByCity = true
        if shouldReturnError { throw URLError(.notConnectedToInternet) }
        return stubbedPlaces
    }
}
