//
//  FourSquareServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

protocol FourSquareServiceProtocol {
    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace]
    func searchPlaces(query: String, latitude: Double, longitude: Double) async throws -> [FSQPlace]
    func autocompleteLocation(query: String) async throws -> [FSQPlace]
    func fetchPlaces(near city: String, categoryID: String, limit: Int) async throws -> [FSQPlace]
    
    func searchPlacesByCity(near city: String, query: String, limit: Int) async throws -> [FSQPlace]
}
