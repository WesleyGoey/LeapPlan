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
    let location: FSQLocation?
    let geocodes: FSQGeocodes?

    var id: String { fsq_place_id }
    
    var latitude: Double? { geocodes?.main?.latitude }
    var longitude: Double? { geocodes?.main?.longitude }

    enum CodingKeys: String, CodingKey {
        case fsq_place_id = "fsq_id"
        case name, distance, location, geocodes
    }

    static func == (lhs: FSQPlace, rhs: FSQPlace) -> Bool {
        return lhs.fsq_place_id == rhs.fsq_place_id
    }
}

// MARK: - Helper Structs
struct FSQLocation: Codable {
    let locality: String?
    let country: String?
}

struct FSQGeocodes: Codable {
    let main: FSQCoordinate?
}

struct FSQCoordinate: Codable {
    let latitude: Double?
    let longitude: Double?
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
