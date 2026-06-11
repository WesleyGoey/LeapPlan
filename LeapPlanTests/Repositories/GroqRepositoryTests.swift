//
//  GroqRepositoryTests.swift
//  LeapPlanTests
//
//  Created by student on 11/06/26.
//

import XCTest
@testable import LeapPlan

// MARK: - URLProtocol Mock
class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var mockResponse: HTTPURLResponse?
    static var mockError: Error?
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool { return true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

    override func startLoading() {
        if let handler = MockURLProtocol.requestHandler {
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
            return
        }

        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = MockURLProtocol.mockResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = MockURLProtocol.mockData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

final class GroqRepositoryTests: XCTestCase {
    var repository: GroqRepository!

    override func setUp() {
        super.setUp()
        // Replace URLProtocol in default session is not possible directly without injecting session, 
        // but URLProtocol registerClass intercepts shared session calls too if properly configured.
        URLProtocol.registerClass(MockURLProtocol.self)
        repository = GroqRepository()
    }

    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = nil
        MockURLProtocol.requestHandler = nil
        repository = nil
        super.tearDown()
    }

    func testFetchGroqResponse_Success() async throws {
        // Arrange
        let expectedText = "Mock test response"
        let jsonResponse = """
        {
            "choices": [
                {
                    "message": {
                        "role": "assistant",
                        "content": "\(expectedText)"
                    }
                }
            ]
        }
        """
        MockURLProtocol.mockData = jsonResponse.data(using: .utf8)
        MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: "https://api.groq.com/openai/v1/chat/completions")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let request = GroqRequest(model: "llama", messages: [GroqMessage(role: "user", content: "Test")])

        // Act
        let response = try await repository.fetchGroqResponse(payload: request)

        // Assert
        XCTAssertEqual(response.choices?.first?.message?.content, expectedText)
    }
    
    func testFetchGroqResponse_FailureStatusCode() async {
        // Arrange
        let jsonResponse = """
        {
            "error": "Unauthorized"
        }
        """
        MockURLProtocol.mockData = jsonResponse.data(using: .utf8)
        MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: "https://api.groq.com/openai/v1/chat/completions")!, statusCode: 401, httpVersion: nil, headerFields: nil)

        let request = GroqRequest(model: "llama", messages: [GroqMessage(role: "user", content: "Test")])

        // Act & Assert
        do {
            _ = try await repository.fetchGroqResponse(payload: request)
            XCTFail("Expected URLError(.badServerResponse)")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .badServerResponse)
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}
