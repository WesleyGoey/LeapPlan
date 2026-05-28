//
//  TripsViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//


import XCTest
import Combine
@testable import LeapPlan

@MainActor
final class TripsViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() { super.setUp(); cancellables = [] }

    func testCreateManualTrip_UpdatesList() async {
        let mockRepo = MockTripRepository()
        let viewModel = TripsViewModel(tripRepository: mockRepo, authService: MockAuthService(), tripGenService: MockTripGenerationService())
        
        let expectation = XCTestExpectation(description: "Wait for list refresh")
        viewModel.$trips.dropFirst().sink { _ in expectation.fulfill() }.store(in: &cancellables)

        viewModel.createManualTrip(title: "Tokyo", location: "Japan", start: Date(), end: Date())
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(mockRepo.mockTrips.first?.title, "Tokyo")
    }
}