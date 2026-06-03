//
//  SearchViewModelTests.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import XCTest
import Combine
@testable import LeapPlan

@MainActor
final class SearchViewModelTests: XCTestCase {
    var sut: SearchViewModel!
    var mockFourSquareService: MockFourSquareService!
    var mockLocationService: MockLocationService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockFourSquareService = MockFourSquareService()
        mockLocationService = MockLocationService()
        
        sut = SearchViewModel(
            fourSquareService: mockFourSquareService,
            locationService: mockLocationService
        )
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockFourSquareService = nil
        mockLocationService = nil
        try super.tearDownWithError()
    }
    
    func test_searchQuery_whenTyping_shouldTriggerAutocomplete() async {
        // Given
        sut.searchQuery = "Kopi"
        // When -> debounce will trigger in ViewModel
        try? await Task.sleep(nanoseconds: 600_000_000) // Tunggu debounce > 500ms
        
        // Then
        // Lakukan assert terhadap state pencarian kamu
    }
}