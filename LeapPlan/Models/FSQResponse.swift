//
//  FSQPlace.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//

import CoreLocation
import Foundation

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

// MARK: - MapKit Compatibility Extension
extension FSQPlace {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude ?? -7.2504,
            longitude: longitude ?? 112.7688
        )
    }
}
