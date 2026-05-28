//
//  TripDestination.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import Foundation
import CoreLocation

struct TripDestination: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var category: String       // Contoh: "Tempat Makan", "Objek Wisata", "Hotel"
    var foursquareID: String?  // ID untuk menarik data detail & foto dari API FourSquare
    
    // Koordinat untuk Apple MapKit (Pins)
    var latitude: Double
    var longitude: Double
    
    // Logika Timeline
    var orderIndex: Int          // Urutan kunjungan dalam satu hari (0, 1, 2, dst.)
    var stayDurationMinutes: Int // Berapa lama stay di lokasi ini (contoh: 120 untuk 2 jam)
    
    // Waktu transit (waktu dari lokasi ini ke lokasi berikutnya).
    // Bisa disimpan di database atau dihitung secara on-the-fly oleh MapKit di ViewModel.
    var transitTimeToNextMinutes: Int?
    
    static func == (lhs: TripDestination, rhs: TripDestination) -> Bool {
        return lhs.id == rhs.id
    }
}

extension TripDestination {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
