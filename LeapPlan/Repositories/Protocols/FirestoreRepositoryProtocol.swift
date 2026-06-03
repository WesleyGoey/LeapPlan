//
//  FirestoreRepositoryProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import Foundation
import MapKit

protocol FirestoreRepositoryProtocol {
    // Trip CRUD
    func fetchTrips(forUserID userID: String) async throws -> [Trip]
    func createTrip(_ trip: Trip, forUserID userID: String) async throws
    func updateTrip(_ trip: Trip, forUserID userID: String) async throws
    func deleteTrip(tripID: String, forUserID userID: String) async throws
    
    // DayPlan CRUD
    func fetchDayPlans(forTripID tripID: String, userID: String) async throws -> [DayPlan]
    func saveDayPlan(_ dayPlan: DayPlan, forTripID tripID: String, userID: String) async throws
    func deleteDayPlan(planID: String, tripID: String, userID: String) async throws
    
    // Batch Write
    func saveGeneratedTripWithDayPlans(trip: Trip, dayPlans: [DayPlan], userID: String) async throws
}
