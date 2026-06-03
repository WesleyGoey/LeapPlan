//
//  MockTripService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


//
//  MockTripService.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Foundation
@testable import LeapPlan

class MockTripService: TripServiceProtocol {
    var stubbedDayPlans: [DayPlan] = []
    var shouldThrowError = false
    var didCallGenerateRandomItinerary = false

    func generateRandomItinerary(preferences: RandomTripPreferences) async throws -> [DayPlan] {
        didCallGenerateRandomItinerary = true
        if shouldThrowError { throw NSError(domain: "MockTripService", code: 500, userInfo: [NSLocalizedDescriptionKey: "AI Generation gagal"]) }
        return stubbedDayPlans
    }
}