//
//  SearchViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//


import XCTest
import Combine
@testable import LeapPlan

@MainActor
final class SearchViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() { super.setUp(); cancellables = [] }

    func testPerformSearch_Success() async {
        let mockService = MockFourSquareService()
        mockService.mockPlaces = [FSQPlace(fsq_id: "1", name: "Pakuwon Mall", distance: 50)]
        let viewModel = SearchViewModel(fourSquareService: mockService, locationService: MockLocationService())
        viewModel.searchQuery = "Mall"
        
        let expectation = XCTestExpectation(description: "Wait for search")
        viewModel.$searchResults.dropFirst().sink { if !$0.isEmpty { expectation.fulfill() } }.store(in: &cancellables)

        viewModel.performSearch()
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(viewModel.searchResults.count, 1)
    }
}