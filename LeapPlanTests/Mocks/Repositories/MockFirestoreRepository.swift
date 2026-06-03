//
//  MockFirestoreRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import Foundation
@testable import LeapPlan

class MockFirestoreRepository: FirestoreRepositoryProtocol {
    // Simulasi database di dalam memori
    var trips: [String: [Trip]] = [:] // Key: userID
    var dayPlans: [String: [DayPlan]] = [:] // Key: tripID
    
    // Flag untuk mensimulasikan kegagalan jaringan/Firebase
    var shouldThrowError = false
    
    // MARK: - Trip Operations
    func fetchTrips(forUserID userID: String) async throws -> [Trip] {
        if shouldThrowError { throw NSError(domain: "MockFirestore", code: 500) }
        return trips[userID] ?? []
    }

    func createTrip(_ trip: Trip, forUserID userID: String) async throws {
        if shouldThrowError { throw NSError(domain: "MockFirestore", code: 500) }
        var userTrips = trips[userID] ?? []
        var newTrip = trip
        if newTrip.id == nil { newTrip.id = UUID().uuidString }
        userTrips.append(newTrip)
        trips[userID] = userTrips
    }

    func updateTrip(_ trip: Trip, forUserID userID: String) async throws {
        if shouldThrowError { throw NSError(domain: "MockFirestore", code: 500) }
        guard let tripID = trip.id, var userTrips = trips[userID] else { return }
        if let index = userTrips.firstIndex(where: { $0.id == tripID }) {
            userTrips[index] = trip
            trips[userID] = userTrips
        }
    }

    func deleteTrip(tripID: String, forUserID userID: String) async throws {
        if shouldThrowError { throw NSError(domain: "MockFirestore", code: 500) }
        trips[userID]?.removeAll { $0.id == tripID }
        dayPlans.removeValue(forKey: tripID) // Bersihkan juga day plans terkait
    }

    // MARK: - DayPlan Operations
    func fetchDayPlans(forTripID tripID: String, userID: String) async throws -> [DayPlan] {
        if shouldThrowError { throw NSError(domain: "MockFirestore", code: 500) }
        return dayPlans[tripID] ?? []
    }

    func saveDayPlan(_ dayPlan: DayPlan, forTripID tripID: String, userID: String) async throws {
        if shouldThrowError { throw NSError(domain: "MockFirestore", code: 500) }
        var plans = dayPlans[tripID] ?? []
        var newPlan = dayPlan
        if newPlan.id == nil { newPlan.id = UUID().uuidString }
        
        if let index = plans.firstIndex(where: { $0.id == newPlan.id }) {
            plans[index] = newPlan
        } else {
            plans.append(newPlan)
        }
        dayPlans[tripID] = plans
    }

    func deleteDayPlan(planID: String, tripID: String, userID: String) async throws {
        if shouldThrowError { throw NSError(domain: "MockFirestore", code: 500) }
        dayPlans[tripID]?.removeAll { $0.id == planID }
    }

    // MARK: - Batch Write
    func saveGeneratedTripWithDayPlans(trip: Trip, dayPlans: [DayPlan], userID: String) async throws {
        if shouldThrowError { throw NSError(domain: "MockFirestore", code: 500) }
        try await createTrip(trip, forUserID: userID)
        guard let tripID = trip.id else { return }
        for plan in dayPlans {
            try await saveDayPlan(plan, forTripID: tripID, userID: userID)
        }
    }
}
