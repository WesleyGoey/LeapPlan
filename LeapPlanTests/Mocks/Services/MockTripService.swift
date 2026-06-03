//
//  MockTripService.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//


import Foundation
@testable import LeapPlan

class MockTripService: TripServiceProtocol {
    
    // Spies
    var didCallGenerate = false
    
    // Stub
    var mockDayPlans: [DayPlan] = []
    var shouldThrowError = false
    
    func generateRandomItinerary(preferences: RandomTripPreferences) async throws -> [DayPlan] {
        didCallGenerate = true
        if shouldThrowError { throw NSError(domain: "MockTripService", code: 500) }
        return mockDayPlans
    }
}