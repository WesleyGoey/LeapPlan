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
    let fsq_place_id: String  // ID Format Baru Foursquare
    let name: String
    let distance: Int?
    let latitude: Double?     // Koordinat Format Baru
    let longitude: Double?
    
    // 3 Variabel Tambahan untuk UI Dinamis
    let location: FSQLocation?
    let rating: Double?
    let stats: FSQStats?
    
    var id: String { fsq_place_id }

    static func == (lhs: FSQPlace, rhs: FSQPlace) -> Bool {
        return lhs.fsq_place_id == rhs.fsq_place_id
    }
    
    // PENTING: Jika API JSON dari Foursquare tidak "flat" (misal: latitude ada di dalam geocodes),
    // kamu harus menambahkan CodingKeys di sini.
}

// MARK: - Helper Structs
struct FSQLocation: Codable {
    let locality: String? // Nama Kota
    let country: String?  // Nama Negara
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
