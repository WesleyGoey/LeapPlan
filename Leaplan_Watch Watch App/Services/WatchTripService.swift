//
//  WatchTripService.swift
//  Leaplan_Watch Watch App
//
//  Created by Wesley Goey on 10/06/26.
//

import Foundation

class WatchTripService: WatchTripServiceProtocol {
    private let repository: WatchTripRepositoryProtocol

    init(repository: WatchTripRepositoryProtocol = WatchTripRepository()) {
        self.repository = repository
    }

    func getTrips() async throws -> [Trip] {
        return try await repository.fetchTrips()
    }

    func getTripDetails(tripId: String) async throws -> [DayPlan] {
        return try await repository.fetchTripDetails(tripId: tripId)
    }

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

    func saveReorderedDestinations(tripId: String, dayPlan: DayPlan)
        async throws -> Bool
    {
        return try await repository.saveReorderedDestinations(
            tripId: tripId,
            dayPlan: dayPlan
        )
    }
}
