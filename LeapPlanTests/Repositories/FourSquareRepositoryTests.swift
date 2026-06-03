//
//  FourSquareRepositoryTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

\

import XCTest
@testable import LeapPlan

final class FourSquareRepositoryTests: XCTestCase {
    
    var repository: FourSquareRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        repository = FourSquareRepository()
        // Daftarkan MockURLProtocol untuk mencegat semua request URLSession.shared
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    override func tearDownWithError() throws {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        repository = nil
        try super.tearDownWithError()
    }
    
    func testSearchPlaces_Success() async throws {
        // Arrange
        let jsonResponse = """
        {
            "results": [
                {
                    "fsq_place_id": "4b05a544f964a5204b8922e3",
                    "name": "Ciputra World Surabaya",
                    "distance": 120,
                    "latitude": -7.2912,
                    "longitude": 112.7234
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.stubResponseData = jsonResponse
        MockURLProtocol.stubResponse = HTTPURLResponse(
            url: URL(string: "https://places-api.foursquare.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        let places = try await repository.searchPlaces(query: "Ciputra World", latitude: -7.2912, longitude: 112.7234)
        
        // Assert
        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places.first?.name, "Ciputra World Surabaya")
        XCTAssertEqual(places.first?.fsq_place_id, "4b05a544f964a5204b8922e3")
    }
    
    func testFetchPlacePhotos_Success() async throws {
        // Arrange
        let jsonResponse = """
        [
            {
                "prefix": "https://fastly.4sqi.net/img/general/",
                "suffix": "/test.jpg"
            }
        ]
        """.data(using: .utf8)!
        
        MockURLProtocol.stubResponseData = jsonResponse
        MockURLProtocol.stubResponse = HTTPURLResponse(
            url: URL(string: "https://places-api.foursquare.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        let photoUrl = try await repository.fetchPlacePhotos(id: "4b05a544f964a5204b8922e3")
        
        // Assert
        XCTAssertNotNil(photoUrl)
        XCTAssertEqual(photoUrl, "https://fastly.4sqi.net/img/general/500x500/test.jpg")
    }
}

// MARK: - HELPER URL INTERCEPTOR UNTUK URLSESSION.SHARED
class MockURLProtocol: URLProtocol {
    static var stubResponseData: Data?
    static var stubResponse: URLResponse?
    static var stubError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool { return true }
    override class class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }
    
    override func startLoading() {
        if let error = MockURLProtocol.stubError {
            self.client?.urlProtocol(self, didFailWithError: error)
            return
        }
        if let response = MockURLProtocol.stubResponse {
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = MockURLProtocol.stubResponseData {
            self.client?.urlProtocol(self, didLoad: data)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
