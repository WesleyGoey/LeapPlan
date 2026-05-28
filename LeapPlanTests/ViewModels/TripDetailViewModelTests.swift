//
//  TripDetailViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//


import XCTest
import MapKit
@testable import LeapPlan

@MainActor
final class TripDetailViewModelTests: XCTestCase {
    func testRouteCalculation_OnDayChange() {
        let dummyTrip = Trip(id: "t1", title: "Bali", locationName: "Bali", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: [], createdAt: Date(), createdBy: "user1")
        let viewModel = TripDetailViewModel(trip: dummyTrip, tripRepository: MockTripRepository(), authService: MockAuthService())
        
        let dest1 = TripDestination(id: "d1", name: "A", category: "Nature", latitude: -8.4, longitude: 115.1, orderIndex: 0, stayDurationMinutes: 60)
        let dest2 = TripDestination(id: "d2", name: "B", category: "Cafe", latitude: -8.5, longitude: 115.2, orderIndex: 1, stayDurationMinutes: 60)
        
        viewModel.dayPlans = [DayPlan(id: "day1", dayNumber: 1, date: Date(), destinations: [dest1, dest2])]
        viewModel.selectedDayIndex = 0 
        
        XCTAssertNotNil(viewModel.mapRoute)
        XCTAssertEqual(viewModel.mapRoute?.pointCount, 2)
    }
}
