//
//  DayPlanDTO.swift
//  LeapPlan
//

import Foundation

struct DayPlanDTO: Identifiable, Codable {
    var id: String?
    var dayNumber: Int
    var date: Date
    var destinations: [TripDestination]
}
