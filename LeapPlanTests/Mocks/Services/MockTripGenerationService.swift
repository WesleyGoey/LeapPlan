//
//  MockTripGenerationService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
@testable import LeapPlan

class MockTripGenerationService: TripGenerationServiceProtocol {
    var mockDayPlans: [DayPlan] = []
    
    func generateRandomItinerary(preferences: RandomTripPreferences) -> [DayPlan] {
        return mockDayPlans
    }
}