//
//  WatchTripRepositoryProtocol.swift
//  Leaplan_Watch Watch App
//
//  Created by Wesley Goey on 10/06/26.
//

import Foundation

// MARK: - Watch Trip Repository Protocol
protocol WatchTripRepositoryProtocol {
    // MARK: - Fetch Trips
    func fetchTrips() async throws -> [Trip]

    // MARK: - Fetch Trip Details
    func fetchTripDetails(tripId: String) async throws -> [DayPlan]

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
