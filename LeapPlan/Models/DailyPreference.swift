//
//  DailyPreference.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import Foundation

// MARK: - Daily Preference Model
struct DailyPreference: Identifiable, Equatable, Hashable {
    let id = UUID()
    var dayNumber: Int
    var meals: Int
    var places: Int
}
