//
//  WatchTripRepositoryProtocol.swift
//  Leaplan_Watch Watch App
//

import Foundation

protocol WatchTripRepositoryProtocol {
    func fetchTrips() async throws -> [Trip]
    func fetchTripDetails(tripId: String) async throws -> [DayPlan]
}
