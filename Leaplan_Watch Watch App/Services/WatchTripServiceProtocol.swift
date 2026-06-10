//
//  WatchTripServiceProtocol.swift
//  Leaplan_Watch Watch App
//
//  Created by Wesley Goey on 10/06/26.
//

import Foundation

protocol WatchTripServiceProtocol {
    func getTrips() async throws -> [Trip]
    func getTripDetails(tripId: String) async throws -> [DayPlan]
    func generateRandomPlace(
        tripId: String,
        dayPlanId: String,
        tripLocationName: String
    ) async throws -> Bool
    func saveReorderedDestinations(tripId: String, dayPlan: DayPlan)
        async throws -> Bool
}
