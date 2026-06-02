//
//  MockTripGenerationService.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//


import Foundation
@testable import LeapPlan

class MockTripGenerationService: TripGenerationServiceProtocol {
    var mockDayPlans: [DayPlan] = []
    
    // Tambahkan async throws di sini
    func generateRandomItinerary(preferences: RandomTripPreferences) async throws -> [DayPlan] {
        return mockDayPlans
    }
}