//
//  WatchTripServiceProtocol.swift
//  Leaplan_Watch Watch App
//
//  Created by Wesley Goey on 10/06/26.
//

import Foundation

// MARK: - Watch Trip Service Protocol
protocol WatchTripServiceProtocol {
    // MARK: - Get Trips
    func getTrips() async throws -> [Trip]

    // MARK: - Get Trip Details
    func getTripDetails(tripId: String) async throws -> [DayPlan]

    // MARK: - Generate Random Place
    func generateRandomPlace(
        tripId: String,
        dayPlanId: String,
        tripLocationName: String
    ) async throws -> Bool
    
    // MARK: - Save Reordered Destinations
    func saveReorderedDestinations(tripId: String, dayPlan: DayPlan)
        async throws -> Bool
}
