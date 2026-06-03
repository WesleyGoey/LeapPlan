//
//  FourSquareServiceTests.swift
//  LeapPlanTests
//
//  Created by Sean tandjaja on 03/06/26.
//

import XCTest
@testable import LeapPlan

final class FourSquareServiceTests: XCTestCase {
    
    var service: FourSquareService!
    var mockRepo: MockFourSquareRepository!
    
    override func setUp() {
        super.setUp()
        mockRepo = MockFourSquareRepository()
        service = FourSquareService(repo: mockRepo)
    }
    
    override func tearDown() {
        service = nil
        mockRepo = nil
        super.tearDown()
    }
    
    func testFetchTrendingPlaces_WithPhotos_Success() async throws {
        // Arrange
        let dummyPlace = FSQPlace(fsq_place_id: "place_abc", name: "Tunjungan Plaza", distance: 100, latitude: -7.26, longitude: 112.74, location: nil, rating: 4.5, stats: nil, imageURL: nil)
        mockRepo.stubbedPlaces = [dummyPlace]
        mockRepo.stubbedPhotoUrl = "https://images.foursquare.com/mock.jpg"
        
        // Act
        let results = try await service.fetchTrendingPlaces(city: "Surabaya")
        
        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Tunjungan Plaza")
        // Memastikan fungsi attachPhotos di dalam Service berhasil menempelkan URL gambar hasil fetch repo
        XCTAssertEqual(results.first?.imageURL, "https://images.foursquare.com/mock.jpg")
    }
    
    func testSearchPlacesByCity_Failure() async {
        // Arrange
        mockRepo.shouldThrowError = true
        
        // Act & Assert
        do {
            _ = try await service.searchPlacesByCity(near: "Surabaya", query: "Ciputra World", limit: 5)
            XCTFail("Harusnya melempar error saat repo mengalami kegagalan.")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}