//
//  MockFourSquareRepository.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import Foundation
@testable import LeapPlan

class MockFourSquareRepository: FourSquareRepositoryProtocol {
    
    // Flag
    var shouldThrowError = false
    var mockPlaces: [FSQPlace] = []
    var mockPhotoURL: String? = "https://test.com/photo.jpg"
    
    // Spies (Mata-mata)
    var didCallSearchPlaces = false
    var didCallSearchPlacesByCity = false
    var didCallFetchPlaces = false
    var didCallAutocompleteLocation = false
    var didCallFetchPlacePhotos = false
    
    // Definisi Error
    enum MockError: Error {
        case simulatedNetworkError
    }
    
    func searchPlaces(query: String, latitude: Double, longitude: Double) async throws -> [FSQPlace] {
        didCallSearchPlaces = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        return mockPlaces
    }
    
    func searchPlacesByCity(near city: String, query: String, limit: Int) async throws -> [FSQPlace] {
        didCallSearchPlacesByCity = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        return mockPlaces
    }
    
    func fetchPlaces(near city: String, categoryID: String, limit: Int) async throws -> [FSQPlace] {
        didCallFetchPlaces = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        return mockPlaces
    }
    
    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        didCallAutocompleteLocation = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        return mockPlaces
    }
    
    func fetchPlacePhotos(id: String) async throws -> String? {
        didCallFetchPlacePhotos = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        return mockPhotoURL
    }
}
