//
//  WatchTripServiceProtocol.swift
//  Leaplan_Watch Watch App
//

import Foundation

protocol WatchTripServiceProtocol {
    func getTrips() async throws -> [Trip]
    func getTripDetails(tripId: String) async throws -> [DayPlan]
}
