//
//  DayPlanDTO.swift
//  RecipeVault
//
//  Created by Wesley Goey on 31/05/26.
//

import Foundation

struct DayPlanDTO: Identifiable, Codable {
    var id: String?
    var dayNumber: Int
    var date: Date
    var destinations: [TripDestination]
}
