//
//  TripServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


protocol TripServiceProtocol {
    func generateRandomItinerary(preferences: RandomTripPreferences) async throws -> [DayPlan]
}