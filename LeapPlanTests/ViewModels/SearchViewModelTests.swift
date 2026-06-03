//
//  SearchViewModelTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import XCTest
import MapKit
@testable import LeapPlan

final class SearchViewModelTests: XCTestCase {
    
    private var mockFourSquareService: MockFourSquareService!
    private var mockLocationService: MockLocationService!
    private var mockAuthService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        mockFourSquareService = MockFourSquareService()
        mockLocationService = MockLocationService()
        mockAuthService = MockAuthService()
    }
    
    override func tearDown() {
        mockFourSquareService = nil
        mockLocationService = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    @MainActor
    func testPerformSearch_Success_PopulatesSearchResults() async {
        // Arrange
        let dummyPlace = FSQPlace(fsq_place_id: "fsq_123", name: "Pakwon Mall", distance: 500, latitude: -7.2, longitude: 112.6, location: nil, rating: nil, stats: nil, imageURL: nil)
        mockFourSquareService.stubbedPlaces = [dummyPlace]
        
        let viewModel = SearchViewModel(fourSquareService: mockFourSquareService, locationService: mockLocationService, authService: mockAuthService)
        viewModel.searchQuery = "Pakuwon"
        
        // Act
        viewModel.performSearch()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertTrue(mockFourSquareService.didCallSearchPlaces)
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.name, "Pakwon Mall")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    @MainActor
    func testSelectPlace_FocusesCameraAndPins() {
        // Arrange
        let viewModel = SearchViewModel(fourSquareService: mockFourSquareService, locationService: mockLocationService, authService: mockAuthService)
        let place = FSQPlace(fsq_place_id: "1", name: "UC Loop", distance: nil, latitude: -7.28, longitude: 112.64, location: nil, rating: nil, stats: nil, imageURL: nil)
        
        // Act
        viewModel.selectPlace(place)
        
        // Assert
        XCTAssertEqual(viewModel.selectedPlace, place)
        XCTAssertEqual(viewModel.searchQuery, "UC Loop")
        XCTAssertEqual(viewModel.displayedPins.count, 1)
        XCTAssertEqual(viewModel.displayedPins.first?.name, "UC Loop")
    }
}
