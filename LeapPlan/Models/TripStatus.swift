//
//  TripStatus.swift
//  LeapPlan
//
//  Created by Wesley Goey on 29/05/26.
//


import Foundation
import FirebaseFirestore

enum TripStatus: String, Codable {
    case upcoming = "Upcoming"
    case ongoing = "Ongoing"
    case completed = "Completed"
}