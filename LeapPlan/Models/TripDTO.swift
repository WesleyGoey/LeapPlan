//
//  TripDTO.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import Foundation

struct TripDTO: Codable {
    var id: String?
    var title: String
    var locationName: String
    var startDate: Date
    var endDate: Date
    var status: TripStatus
    var coverImageUrl: String?
    var participantIDs: [String]
    var totalPlaces: Int
    var createdAt: Date
    var createdBy: String
}
