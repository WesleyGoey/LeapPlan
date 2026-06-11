#if os(watchOS)
//
//  WatchTripService.swift
//  Leaplan_Watch Watch App
//
//  Created by Wesley Goey on 10/06/26.
//

import Foundation

// MARK: - Watch Trip Service
class WatchTripService: WatchTripServiceProtocol {
    private let repository: WatchTripRepositoryProtocol

    init(repository: WatchTripRepositoryProtocol = WatchTripRepository()) {
        self.repository = repository
    }

    // MARK: - Get Trips
    func getTrips() async throws -> [Trip] {
        return try await repository.fetchTrips()
    }

    // MARK: - Get Trip Details
    func getTripDetails(tripId: String) async throws -> [DayPlan] {
        return try await repository.fetchTripDetails(tripId: tripId)
    }

    // MARK: - Generate Random Place
    func generateRandomPlace(
        tripId: String,
        dayPlanId: String,
        tripLocationName: String
    ) async throws -> Bool {
        return try await repository.generateRandomPlace(
            tripId: tripId,
            dayPlanId: dayPlanId,
            tripLocationName: tripLocationName
        )
    }

    // MARK: - Save Reordered Destinations
    func saveReorderedDestinations(tripId: String, dayPlan: DayPlan)
        async throws -> Bool
    {
        return try await repository.saveReorderedDestinations(
            tripId: tripId,
            dayPlan: dayPlan
        )
    }
}

#endif
