//
//  TripDestinationServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

protocol TripDestinationServiceProtocol {
    func addPlaceToTrip(
        place: FSQPlace,
        targetTrip: Trip,
        selectedDays: Set<Int>,
        userID: String
    ) async throws

    func removePlaceFromTrip(
        placeID: String,
        tripID: String,
        dayNum: Int,
        userID: String
    ) async throws

    func saveReorderedDestinations(
        dayPlan: DayPlan,
        tripID: String,
        userID: String
    ) async throws
    func calculateTimeline(
        for destination: TripDestination,
        in dayPlan: DayPlan
    ) -> String
}
