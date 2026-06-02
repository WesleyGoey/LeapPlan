//
//  FSQPlace.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//


import Foundation
import CoreLocation

// MARK: - Main Place Model
struct FSQPlace: Identifiable, Codable, Equatable {
    let fsq_place_id: String  // ID Format Baru Foursquare
    let name: String
    let distance: Int?
    let latitude: Double?     // Koordinat Format Baru Foursquare
    let longitude: Double?
    
    var id: String { fsq_place_id }

    static func == (lhs: FSQPlace, rhs: FSQPlace) -> Bool {
        return lhs.fsq_place_id == rhs.fsq_place_id
    }
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
