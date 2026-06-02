//
//  TripGenerationServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

protocol TripGenerationServiceProtocol {
    func generateRandomItinerary(preferences: RandomTripPreferences) async throws -> [DayPlan]
}
