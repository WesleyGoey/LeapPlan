//
//  FSQResponse.swift
//  LeapPlan
//
//  Created by Wesley Goey on 31/05/26.
//


import Foundation
import CoreLocation

// MARK: - API Response Wrapper
struct FSQResponse: Codable {
    let results: [FSQPlace]
}

// MARK: - Main Place Model (Disesuaikan dengan format JSON baru)
struct FSQPlace: Identifiable, Codable, Equatable {
    let fsq_place_id: String  // PERUBAHAN 3: Dulunya fsq_id
    let name: String
    let distance: Int?
    let latitude: Double?     // PERUBAHAN 4: Dulunya ada di dalam struct geocodes
    let longitude: Double?
    
    var id: String { fsq_place_id }

    static func == (lhs: FSQPlace, rhs: FSQPlace) -> Bool {
        return lhs.fsq_place_id == rhs.fsq_place_id
    }
}

// (Struct FSQGeocodes dan FSQCoordinate DIHAPUS karena Foursquare tidak memakainya lagi)

// MARK: - MapKit Compatibility Extension
extension FSQPlace {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude ?? -7.2504,
            longitude: longitude ?? 112.7688
        )
    }
}
