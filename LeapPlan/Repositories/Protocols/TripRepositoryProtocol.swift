//
//  TripRepositoryProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

protocol TripRepositoryProtocol {
    // MARK: - Trip Operations
    func fetchTrips(forUserID userID: String) async throws -> [Trip]
    func createTrip(_ trip: Trip, forUserID userID: String) async throws
    func updateTrip(_ trip: Trip, forUserID userID: String) async throws
    func deleteTrip(tripID: String, forUserID userID: String) async throws
    
    // MARK: - DayPlan Operations
    func fetchDayPlans(forTripID tripID: String, userID: String) async throws -> [DayPlan]
    func saveDayPlan(_ dayPlan: DayPlan, forTripID tripID: String, userID: String) async throws
    
    // ⬇️ TAMBAHKAN BARIS BARU INI DI DALAM PROTOKOL ⬇️
    func saveGeneratedTripWithDayPlans(trip: Trip, dayPlans: [DayPlan], userID: String) async throws
}
