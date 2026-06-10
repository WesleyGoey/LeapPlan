//
//  FourSquareRepositoryProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation
import MapKit

protocol FourSquareRepositoryProtocol {
    // MARK: - Search Places
    func searchPlaces(query: String, latitude: Double, longitude: Double)
        async throws -> [FSQPlace]
    // MARK: - Fetch Places
    func fetchPlaces(near city: String, categoryID: String, limit: Int)
        async throws -> [FSQPlace]
    // MARK: - Autocomplete Location
    func autocompleteLocation(query: String) async throws -> [FSQPlace]
    // MARK: - Search Places By City
    func searchPlacesByCity(near city: String, query: String, limit: Int)
        async throws -> [FSQPlace]
}
