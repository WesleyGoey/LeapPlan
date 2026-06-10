//
//  TripServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

protocol TripServiceProtocol {
    // MARK: - Generate Random Itinerary
    func generateRandomItinerary(preferences: RandomTripPreferences)
        async throws -> [DayPlan]
}
