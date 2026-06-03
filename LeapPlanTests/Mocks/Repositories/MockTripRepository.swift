//
//  MockTripRepository.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import Foundation
@testable import LeapPlan

class MockTripRepository: FirestoreRepositoryProtocol {
    var stubbedTrips: [Trip] = []
    var stubbedDayPlans: [DayPlan] = []
    var shouldThrowError: Bool = false
    
    // Variabel untuk mengecek apakah fungsi dipanggil
    var didCallFetchTrips = false
    var didCallDeleteTrip = false
    var deletedTripID: String? = nil
    
    func fetchTrips(forUserID userID: String) async throws -> [Trip] {
        didCallFetchTrips = true
        if shouldThrowError { throw URLError(.cannotConnectToHost) }
        return stubbedTrips
    }
    
    func deleteTrip(tripID: String, forUserID userID: String) async throws {
        didCallDeleteTrip = true
        deletedTripID = tripID
        if shouldThrowError { throw URLError(.cannotConnectToHost) }
    }
    
    // Tambahkan dummy method lain yang diwajibkan oleh FirestoreRepositoryProtocol
    func updateTrip(_ trip: Trip, forUserID userID: String) async throws {}
    func fetchDayPlans(forTripID tripID: String, userID: String) async throws -> [DayPlan] { return stubbedDayPlans }
    func saveDayPlan(_ plan: DayPlan, forTripID tripID: String, userID: String) async throws {}
    func deleteDayPlan(planID: String, tripID: String, userID: String) async throws {}
    func saveGeneratedTripWithDayPlans(trip: Trip, dayPlans: [DayPlan], userID: String) async throws {}
}