//
//  WatchTripRepositoryProtocol.swift
//  Leaplan_Watch Watch App
//

import Foundation

protocol WatchTripRepositoryProtocol {
    func fetchTrips() async throws -> [Trip]
    func fetchTripDetails(tripId: String) async throws -> [DayPlan]
    func generateRandomPlace(tripId: String, dayPlanId: String, tripLocationName: String) async throws -> Bool
    func saveReorderedDestinations(tripId: String, dayPlan: DayPlan) async throws -> Bool
}
