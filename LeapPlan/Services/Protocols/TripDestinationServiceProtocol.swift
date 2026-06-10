//
//  TripDestinationServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

protocol TripDestinationServiceProtocol {
    // MARK: - Add Place To Trip
    func addPlaceToTrip(
        place: FSQPlace,
        targetTrip: Trip,
        selectedDays: Set<Int>,
        userID: String
    ) async throws

    // MARK: - Remove Place From Trip
    func removePlaceFromTrip(
        placeID: String,
        tripID: String,
        dayNum: Int,
        userID: String
    ) async throws

    // MARK: - Save Reordered Destinations
    func saveReorderedDestinations(
        dayPlan: DayPlan,
        tripID: String,
        userID: String
    ) async throws
    // MARK: - Calculate Timeline
    func calculateTimeline(
        for destination: TripDestination,
        in dayPlan: DayPlan
    ) -> String
}
