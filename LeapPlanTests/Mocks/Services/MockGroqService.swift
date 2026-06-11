//
//  MockGroqService.swift
//  LeapPlan
//
//  Created by student on 11/06/26.
//

import Foundation

@testable import LeapPlan

class MockGroqService: GroqServiceProtocol {
    var shouldThrowError = false
    var mockResponse: String = "Mocked Groq Service Response"
    
    var didCallSendMessage = false

    func sendMessage(chatHistory: [ChatMessage]) async throws -> String {
        didCallSendMessage = true
        
        if shouldThrowError {
            throw NSError(domain: "MockGroqService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated network error"])
        }
        
        return mockResponse
    }
}
