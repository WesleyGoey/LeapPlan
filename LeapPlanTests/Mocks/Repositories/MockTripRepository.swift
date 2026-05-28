//
//  MockTripRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
@testable import LeapPlan

class MockTripRepository: TripRepositoryProtocol {
    var shouldReturnError = false
    var mockTrips: [Trip] = []
    var mockDayPlans: [DayPlan] = []
    
    // MARK: - Trip Operations
    func fetchTrips(forUserID userID: String) async throws -> [Trip] {
        if shouldReturnError { throw URLError(.badServerResponse) }
        return mockTrips
    }
    
    func createTrip(_ trip: Trip, forUserID userID: String) async throws {
        if shouldReturnError { throw URLError(.badServerResponse) }
        mockTrips.append(trip)
    }
    
    func updateTrip(_ trip: Trip, forUserID userID: String) async throws {
        if shouldReturnError { throw URLError(.badServerResponse) }
        if let index = mockTrips.firstIndex(where: { $0.id == trip.id }) {
            mockTrips[index] = trip
        }
    }
    
    func deleteTrip(tripID: String, forUserID userID: String) async throws {
        if shouldReturnError { throw URLError(.badServerResponse) }
        mockTrips.removeAll(where: { $0.id == tripID })
    }
    
    // MARK: - DayPlan Operations
    func fetchDayPlans(forTripID tripID: String, userID: String) async throws -> [DayPlan] {
        if shouldReturnError { throw URLError(.badServerResponse) }
        return mockDayPlans
    }
    
    func saveDayPlan(_ dayPlan: DayPlan, forTripID tripID: String, userID: String) async throws {
        if shouldReturnError { throw URLError(.badServerResponse) }
        mockDayPlans.append(dayPlan)
    }
}