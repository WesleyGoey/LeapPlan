//
//  MockTripDestinationService.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import Foundation
@testable import LeapPlan

class MockTripDestinationService: TripDestinationServiceProtocol {
    var didCallAddPlace = false
    var didCallRemovePlace = false
    var shouldThrowError = false
    
    func addPlaceToTrip(place: FSQResponse, targetTrip: Trip, selectedDays: [Int], userID: String) async throws {
        didCallAddPlace = true
        if shouldThrowError { throw URLError(.cannotCreateFile) }
    }
    
    func removePlaceFromTrip(placeID: String, tripID: String, dayNum: Int, userID: String) async throws {
        didCallRemovePlace = true
        if shouldThrowError { throw URLError(.fileDoesNotExist) }
    }
}