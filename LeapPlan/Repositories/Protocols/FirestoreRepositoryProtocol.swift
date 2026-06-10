//
//  FirestoreRepositoryProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation
import MapKit

protocol FirestoreRepositoryProtocol {
    // MARK: - Fetch Trips
    func fetchTrips(forUserID userID: String) async throws -> [Trip]
    // MARK: - Create Trip
    func createTrip(_ trip: Trip, forUserID userID: String) async throws
    // MARK: - Update Trip
    func updateTrip(_ trip: Trip, forUserID userID: String) async throws
    // MARK: - Delete Trip
    func deleteTrip(tripID: String, forUserID userID: String) async throws

    // MARK: - Fetch Day Plans
    func fetchDayPlans(forTripID tripID: String, userID: String) async throws
        -> [DayPlan]
    // MARK: - Save Day Plan
    func saveDayPlan(
        _ dayPlan: DayPlan,
        forTripID tripID: String,
        userID: String
    ) async throws
    // MARK: - Delete Day Plan
    func deleteDayPlan(planID: String, tripID: String, userID: String)
        async throws

    // MARK: - Save Generated Trip With Day Plans
    func saveGeneratedTripWithDayPlans(
        trip: Trip,
        dayPlans: [DayPlan],
        userID: String
    ) async throws
}
