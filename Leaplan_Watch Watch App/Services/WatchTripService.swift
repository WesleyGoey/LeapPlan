//
//  WatchTripService.swift
//  Leaplan_Watch Watch App
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
}
