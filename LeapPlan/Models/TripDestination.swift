//
//  TripDestination.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import CoreLocation
import Foundation

struct TripDestination: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var category: String
    var foursquareID: String?

    var latitude: Double
    var longitude: Double

    var orderIndex: Int
    var stayDurationMinutes: Int

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
