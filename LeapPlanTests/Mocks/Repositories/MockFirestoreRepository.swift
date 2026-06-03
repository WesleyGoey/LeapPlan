//
//  MockFirestoreRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation

@testable import LeapPlan

class MockFirestoreRepository: FirestoreRepositoryProtocol {
    var mockTrips: [String: [Trip]] = [:]
    var mockDayPlans: [String: [DayPlan]] = [:]

    var didCallFetchTrips = false
    var didCallCreateTrip = false
    var didCallUpdateTrip = false
    var didCallDeleteTrip = false
    var didCallFetchDayPlans = false
    var didCallSaveDayPlan = false
    var didCallDeleteDayPlan = false
    var didCallSaveGeneratedTrip = false

    func fetchTrips(forUserID userID: String) async throws -> [Trip] {
        didCallFetchTrips = true
        return mockTrips[userID] ?? []
    }

    func createTrip(_ trip: Trip, forUserID userID: String) async throws {
        didCallCreateTrip = true
        var newTrip = trip

        if newTrip.id == nil {
            newTrip.id = UUID().uuidString
        }

        mockTrips[userID, default: []].append(newTrip)
    }

    func updateTrip(_ trip: Trip, forUserID userID: String) async throws {
        didCallUpdateTrip = true
        guard let id = trip.id,
            let index = mockTrips[userID]?.firstIndex(where: { $0.id == id })
        else { return }
        mockTrips[userID]?[index] = trip
    }

    func deleteTrip(tripID: String, forUserID userID: String) async throws {
        didCallDeleteTrip = true
        mockTrips[userID]?.removeAll { $0.id == tripID }
    }

    func fetchDayPlans(forTripID tripID: String, userID: String) async throws
        -> [DayPlan]
    {
        didCallFetchDayPlans = true
        return mockDayPlans[tripID] ?? []
    }

    func saveDayPlan(
        _ dayPlan: DayPlan,
        forTripID tripID: String,
        userID: String
    ) async throws {
        didCallSaveDayPlan = true
        var plans = mockDayPlans[tripID] ?? []
        if let index = plans.firstIndex(where: { $0.id == dayPlan.id }) {
            plans[index] = dayPlan
        } else {
            plans.append(dayPlan)
        }
        mockDayPlans[tripID] = plans
    }

    func deleteDayPlan(planID: String, tripID: String, userID: String)
        async throws
    {
        didCallDeleteDayPlan = true
        mockDayPlans[tripID]?.removeAll { $0.id == planID }
    }

    func saveGeneratedTripWithDayPlans(
        trip: Trip,
        dayPlans: [DayPlan],
        userID: String
    ) async throws {
        didCallSaveGeneratedTrip = true
        var newTrip = trip
        newTrip.id = UUID().uuidString
        mockTrips[userID, default: []].append(newTrip)
        mockDayPlans[newTrip.id!] = dayPlans
    }
}
