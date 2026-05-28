//
//  TripRepositoryProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

protocol TripRepositoryProtocol {
    func fetchTrips(forUserID userID: String) async throws -> [Trip]
    func createTrip(_ trip: Trip, forUserID userID: String) async throws
    func updateTrip(_ trip: Trip, forUserID userID: String) async throws
    func deleteTrip(tripID: String, forUserID userID: String) async throws
    
    func fetchDayPlans(forTripID tripID: String, userID: String) async throws -> [DayPlan]
    func saveDayPlan(_ dayPlan: DayPlan, forTripID tripID: String, userID: String) async throws
}
