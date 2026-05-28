//
//  RandomTripPreferences.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import Foundation

struct RandomTripPreferences {
    var locationName: String
    var startDate: Date
    var endDate: Date
    var mealsPerDay: Int
    var placesToVisitPerDay: Int
    
    var totalDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }
}
