//
//  FSQPlace.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//

import Foundation
import CoreLocation

// MARK: - API Response Wrapper
struct FSQResponse: Codable {
    let results: [FSQPlace]
}

// MARK: - Main Place Model
struct FSQPlace: Identifiable, Codable, Equatable {
    let fsq_place_id: String
    let name: String
    let distance: Int?
    let latitude: Double?
    let longitude: Double?
    
    let location: FSQLocation?
    let rating: Double?
    let stats: FSQStats?
    
    // REVISI: Tambahkan penampung URL Gambar
    var imageURL: String?
    
    var id: String { fsq_place_id }

    static func == (lhs: FSQPlace, rhs: FSQPlace) -> Bool {
        return lhs.fsq_place_id == rhs.fsq_place_id
    }
}

// MARK: - Helper Structs
struct FSQLocation: Codable {
    let locality: String?
    let country: String?
}

struct FSQStats: Codable {
    let total_ratings: Int?
}

// MARK: - MapKit Compatibility Extension
extension FSQPlace {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude ?? -7.2504,
            longitude: longitude ?? 112.7688
        )
    }
}
