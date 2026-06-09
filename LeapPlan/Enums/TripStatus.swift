//
//  TripStatus.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//

import Foundation

enum TripStatus: String, Codable, Hashable {
    case upcoming = "Upcoming"
    case ongoing = "Ongoing"
    case past = "Past"
}
