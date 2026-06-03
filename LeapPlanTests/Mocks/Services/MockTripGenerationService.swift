//
//  MockTripGenerationService.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import Foundation
@testable import LeapPlan

class MockTripGenerationService: TripServiceProtocol {
    var stubbedDayPlans: [DayPlan] = []
    var shouldThrowError = false
    
    func generateRandomItinerary(preferences: RandomTripPreferences) async throws -> [DayPlan] {
        if shouldThrowError { throw URLError(.badServerResponse) }
        return stubbedDayPlans
    }
}