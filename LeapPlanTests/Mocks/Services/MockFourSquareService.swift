//
//  MockFourSquareService.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import Combine
import Foundation

@testable import LeapPlan

class MockFourSquareService: FourSquareServiceProtocol {
    @Published var mockPlaces: [FSQPlace] = []

    // TAMBAHKAN INI
    var shouldThrowError = false
    enum MockError: Error { case serviceError }

    var didCallFetchTrending = false
    var didCallSearchPlaces = false
    var didCallAutocomplete = false
    var didCallFetchPlaces = false
    var didCallSearchByCity = false

    // Update semua fungsi untuk mengecek error
    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace] {
        didCallFetchTrending = true
        if shouldThrowError { throw MockError.serviceError }
        return mockPlaces
    }

    func searchPlaces(query: String, latitude: Double, longitude: Double)
        async throws -> [FSQPlace]
    {
        didCallSearchPlaces = true
        if shouldThrowError { throw MockError.serviceError }
        return mockPlaces
    }

    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        didCallAutocomplete = true
        if shouldThrowError { throw MockError.serviceError }
        return mockPlaces
    }

    func fetchPlaces(near city: String, categoryID: String, limit: Int)
        async throws -> [FSQPlace]
    {
        didCallFetchPlaces = true
        if shouldThrowError { throw MockError.serviceError }
        return mockPlaces
    }

    func searchPlacesByCity(near city: String, query: String, limit: Int)
        async throws -> [FSQPlace]
    {
        didCallSearchByCity = true
        if shouldThrowError { throw MockError.serviceError }
        return mockPlaces
    }
}
