//
//  MockTripDestinationService.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//


import Foundation
@testable import LeapPlan

class MockTripDestinationService: TripDestinationServiceProtocol {
    
    // Spies untuk memverifikasi pemanggilan
    var didCallAddPlace = false
    var didCallRemovePlace = false
    var didCallSaveReorder = false
    
    func addPlaceToTrip(place: FSQPlace, targetTrip: Trip, selectedDays: Set<Int>, userID: String) async throws {
        didCallAddPlace = true
    }
    
    func removePlaceFromTrip(placeID: String, tripID: String, dayNum: Int, userID: String) async throws {
        didCallRemovePlace = true
    }
    
    func saveReorderedDestinations(dayPlan: DayPlan, tripID: String, userID: String) async throws {
        didCallSaveReorder = true
    }
    
    func calculateTimeline(for destination: TripDestination, in dayPlan: DayPlan) -> String {
        return "09:00 AM" // Mock return
    }
}