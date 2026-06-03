//
//  MockTripDestinationService.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Foundation
@testable import LeapPlan

class MockTripDestinationService: TripDestinationServiceProtocol {
    var shouldThrowError = false
    var stubbedTimeline: String = "10:00 AM"
    
    var didCallAddPlace = false
    var didCallRemovePlace = false
    var didCallSaveReordered = false

    func addPlaceToTrip(place: FSQPlace, targetTrip: Trip, selectedDays: Set<Int>, userID: String) async throws {
        didCallAddPlace = true
        if shouldThrowError { throw NSError(domain: "MockDestinationService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gagal menyimpan tempat"]) }
    }
    
    func removePlaceFromTrip(placeID: String, tripID: String, dayNum: Int, userID: String) async throws {
        didCallRemovePlace = true
        if shouldThrowError { throw NSError(domain: "MockDestinationService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gagal menghapus tempat"]) }
    }
    
    func saveReorderedDestinations(dayPlan: DayPlan, tripID: String, userID: String) async throws {
        didCallSaveReordered = true
        if shouldThrowError { throw NSError(domain: "MockDestinationService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gagal menata ulang"]) }
    }
    
    func calculateTimeline(for destination: TripDestination, in dayPlan: DayPlan) -> String {
        return stubbedTimeline
    }
}
