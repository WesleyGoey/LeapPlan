import CoreLocation
import Foundation

// MARK: - API Response Wrapper
struct FSQResponse: Codable {
    let results: [FSQPlace]
}

// MARK: - Main Place Model
struct FSQPlace: Identifiable, Codable, Equatable {
    // Foursquare V3 API mengganti key dari "fsq_place_id" ke "fsq_id"
    // Kita panggil CodingKeys biar di dalem app kita tetep pake variabel fsq_place_id
    enum CodingKeys: String, CodingKey {
        case fsq_place_id = "fsq_id"
        case name, distance, location, rating, stats, photos
        case geocodes
    }

    let fsq_place_id: String
    let name: String
    let distance: Int?
    
    let location: FSQLocation?
    let rating: Double?
    let stats: FSQStats?
    
    // Nangkep array foto mentah dari Foursquare
    let photos: [FSQPhoto]?

    // Nangkep koordinat latitude longitude
    let geocodes: FSQGeocodes?

    var imageURL: String? // Diisi manual lewat helper mapPhotos() di Repository

    var id: String { fsq_place_id }
    
    // Helper buat ngambil lat/long biar kompatibel sama sisa kode lu
    var latitude: Double? { geocodes?.main?.latitude }
    var longitude: Double? { geocodes?.main?.longitude }

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

// 🔥 STRUCT BARU BUAT NANGKEP FOTO
struct FSQPhoto: Codable {
    let prefix: String
    let suffix: String
}

// 🔥 STRUCT BARU BUAT NANGKEP KOORDINAT V3
struct FSQGeocodes: Codable {
    let main: FSQMainGeocode?
}

struct FSQMainGeocode: Codable {
    let latitude: Double
    let longitude: Double
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
