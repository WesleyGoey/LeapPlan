//
//  FourSquareRepositoryProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation
import MapKit

protocol FourSquareRepositoryProtocol {
    func searchPlaces(query: String, latitude: Double, longitude: Double)
        async throws -> [FSQPlace]
    func fetchPlaces(near city: String, categoryID: String, limit: Int)
        async throws -> [FSQPlace]
    func autocompleteLocation(query: String) async throws -> [FSQPlace]
    func searchPlacesByCity(near city: String, query: String, limit: Int)
        async throws -> [FSQPlace]
    func fetchPlacePhotos(id: String) async throws -> String?

}
