import Foundation
import CoreLocation

// MARK: - API Response Wrapper
struct FSQResponse: Codable {
    let results: [FSQPlace]
}
<<<<<<< HEAD
=======

// MARK: - Main Place Model
struct FSQPlace: Identifiable, Codable, Equatable {
    let fsq_place_id: String  // ID Format Baru Foursquare
    let name: String
    let distance: Int?
    let latitude: Double?     // Koordinat Format Baru Foursquare
    let longitude: Double?
    
    // 3 VARIABEL BARU UNTUK UI DINAMIS
    let location: FSQLocation?
    let rating: Double?
    let stats: FSQStats?
    
    var id: String { fsq_place_id }

    static func == (lhs: FSQPlace, rhs: FSQPlace) -> Bool {
        return lhs.fsq_place_id == rhs.fsq_place_id
    }
}

// MARK: - Struct Tambahan untuk Parsing JSON
struct FSQLocation: Codable {
    let locality: String? // Menyimpan Nama Kota
    let country: String?  // Menyimpan Nama Negara
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
>>>>>>> main
