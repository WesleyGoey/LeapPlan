//
//  SearchViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import CoreLocation
import MapKit
import XCTest

@testable import LeapPlan

@MainActor
final class SearchViewModelTests: XCTestCase {

    var viewModel: SearchViewModel!
    var mockFourSquareService: MockFourSquareService!
    var mockLocationService: MockLocationService!
    var mockAuthService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockFourSquareService = MockFourSquareService()
        mockLocationService = MockLocationService()
        mockAuthService = MockAuthService()

        viewModel = SearchViewModel(
            fourSquareService: mockFourSquareService,
            locationService: mockLocationService,
            authService: mockAuthService
        )
    }

    override func tearDown() {
        viewModel = nil
        mockFourSquareService = nil
        mockLocationService = nil
        mockAuthService = nil
        super.tearDown()
    }

    // MARK: - Test Perform Search
    func testPerformSearch() async {
        let dummyPlace = FSQPlace(
            fsq_place_id: "1",
            name: "Pantai Kuta",
            distance: 100,
            location: nil,
            geocodes: FSQGeocodes(main: FSQCoordinate(latitude: -8, longitude: 115))
        )
        mockFourSquareService.mockPlaces = [dummyPlace]
        viewModel.searchQuery = "Pantai"

        viewModel.performSearch()

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockFourSquareService.didCallSearchPlaces)
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.name, "Pantai Kuta")
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Test Select Place
    func testSelectPlace() {
        let place = FSQPlace(
            fsq_place_id: "1",
            name: "Taman Bungkul",
            distance: 0,
            location: nil,
            geocodes: FSQGeocodes(main: FSQCoordinate(latitude: -7, longitude: 112))
        )

        viewModel.selectPlace(place)

        XCTAssertEqual(viewModel.selectedPlace?.name, "Taman Bungkul")
        XCTAssertEqual(viewModel.searchQuery, "Taman Bungkul")
        XCTAssertEqual(viewModel.displayedPins.count, 1)
    }

    // MARK: - Test Center To Current Location
    func testCenterToCurrentLocation() {
        mockLocationService.setDummyLocation(lat: -7.0, lon: 112.0)

        viewModel.centerToCurrentLocation()

        XCTAssertNotNil(viewModel.cameraPosition)
    }

    // MARK: - Test Get Icon For Category
    func getIconForCategory(name: String) -> String {
        let lowerName = name.lowercased()

        if lowerName.contains("apotek") || lowerName.contains("hospital")
            || lowerName.contains("rs")
        {
            return "cross.case.fill"
        }
        if lowerName.contains("kopi") || lowerName.contains("cafe")
            || lowerName.contains("makan") || lowerName.contains("seafood")
        {
            return "cup.and.saucer.fill"
        }
        if lowerName.contains("univ") || lowerName.contains("school") {
            return "graduationcap.fill"
        }
        if lowerName.contains("hotel") {
            return "bed.double.fill"
        }

        return "mappin"
    }

    // MARK: - Test Get Icon For Category
    func testIsLoggedIn() {
        mockAuthService.isLoggedIn = true

        XCTAssertTrue(viewModel.isLoggedIn)

        mockAuthService.isLoggedIn = false

        XCTAssertFalse(viewModel.isLoggedIn)
    }

    // MARK: - Test Debounce Search
    func testSearchQuery() {
        let expectation = XCTestExpectation(description: "Debounce waits 0.5s")

        viewModel.searchQuery = "Surabaya"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertTrue(self.mockFourSquareService.didCallSearchPlaces)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
