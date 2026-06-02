//
//  RandomTripPreferences.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//


import Foundation

// MARK: - Random Trip Preferences
struct RandomTripPreferences {
    var locationName: String
    var startDate: Date
    var endDate: Date
    
    var dailyPreferences: [DailyPreference]
}
