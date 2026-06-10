//
//  WatchTripServiceProtocol.swift
//  Leaplan_Watch Watch App
//

import Foundation

protocol WatchTripServiceProtocol {
    func getTrips() async throws -> [Trip]
    func getTripDetails(tripId: String) async throws -> [DayPlan]
    func generateRandomPlace(tripId: String, dayPlanId: String, tripLocationName: String) async throws -> Bool
    func saveReorderedDestinations(tripId: String, dayPlan: DayPlan) async throws -> Bool
}
