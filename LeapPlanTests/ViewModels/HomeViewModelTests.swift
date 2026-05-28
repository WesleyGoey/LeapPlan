//
//  HomeViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//


import XCTest
import Combine
@testable import LeapPlan

@MainActor
final class HomeViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() { super.setUp(); cancellables = [] }

    func testLoadTrending_Success() async {
        let mockService = MockFourSquareService()
        mockService.mockPlaces = [FSQPlace(fsq_id: "1", name: "Surabaya Cafe", distance: 150)]
        let viewModel = HomeViewModel(fourSquareService: mockService)
        
        let expectation = XCTestExpectation(description: "Wait for data")
        viewModel.$trendingPlaces.dropFirst().sink { if !$0.isEmpty { expectation.fulfill() } }.store(in: &cancellables)

        viewModel.loadTrendingPlaces(for: "Surabaya")
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(viewModel.trendingPlaces.count, 1)
    }
}