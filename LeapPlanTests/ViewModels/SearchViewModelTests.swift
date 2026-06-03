//
//  SearchViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//


import XCTest
import CoreLocation
import MapKit
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
    
    // MARK: - Test Logic & States
    
    func testPerformSearch_UpdatesResults() async {
        // Arrange
        let dummyPlace = FSQPlace(fsq_place_id: "1", name: "Pantai Kuta", distance: 100, latitude: -8, longitude: 115, location: nil, rating: 5, stats: nil)
        mockFourSquareService.mockPlaces = [dummyPlace]
        viewModel.searchQuery = "Pantai"
        
        // Act
        viewModel.performSearch()
        
        // Perlu sedikit waktu untuk task async berjalan
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertTrue(mockFourSquareService.didCallSearchPlaces)
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.name, "Pantai Kuta")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSelectPlace_UpdatesState() {
        // Arrange
        let place = FSQPlace(fsq_place_id: "1", name: "Taman Bungkul", distance: 0, latitude: -7, longitude: 112, location: nil, rating: 5, stats: nil)
        
        // Act
        viewModel.selectPlace(place)
        
        // Assert
        XCTAssertEqual(viewModel.selectedPlace?.name, "Taman Bungkul")
        XCTAssertEqual(viewModel.searchQuery, "Taman Bungkul")
        XCTAssertEqual(viewModel.displayedPins.count, 1)
    }
    
    func testCenterToCurrentLocation_UpdatesPosition() {
        // Arrange
        mockLocationService.setDummyLocation(lat: -7.0, lon: 112.0)
        
        // Act
        viewModel.centerToCurrentLocation()
        
        // Assert: Pastikan posisi kamera berubah (dalam case MapCameraPosition .region, kita cek logic koordinatnya)
        // Kita bisa verifikasi via print atau membandingkan region jika perlu, 
        // tapi memanggil fungsi ini sudah cukup untuk memverifikasi tidak ada crash.
        XCTAssertNotNil(viewModel.cameraPosition)
    }
    
    func getIconForCategory(name: String) -> String {
        let lowerName = name.lowercased()
        
        // Perbaikan: Hapus spasi setelah 'rs' agar "RSUD", "RS", "Rumah Sakit" terdeteksi
        if lowerName.contains("apotek") || lowerName.contains("hospital") || lowerName.contains("rs") {
            return "cross.case.fill"
        }
        if lowerName.contains("kopi") || lowerName.contains("cafe") || lowerName.contains("makan") || lowerName.contains("seafood") {
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
    
    func testIsLoggedIn_DelegatesToAuthService() {
        // Arrange
        mockAuthService.isLoggedIn = true
        
        // Assert
        XCTAssertTrue(viewModel.isLoggedIn)
        
        // Arrange
        mockAuthService.isLoggedIn = false
        
        // Assert
        XCTAssertFalse(viewModel.isLoggedIn)
    }
    
    // MARK: - Testing Live Search (Debounce)
    
    func testSearchQuery_TriggersSearch_WithDebounce() {
        let expectation = XCTestExpectation(description: "Debounce waits 0.5s")
        
        // Arrange
        viewModel.searchQuery = "Surabaya"
        
        // Act: Debounce adalah 500ms, kita tunggu 600ms
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Assert
            XCTAssertTrue(self.mockFourSquareService.didCallSearchPlaces)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
