//
//  MockGroqRepository.swift
//  LeapPlan
//
//  Created by student on 11/06/26.
//

import Foundation

@testable import LeapPlan

class MockGroqRepository: GroqRepositoryProtocol {
    var shouldThrowError = false
    var mockResponse: GroqResponse?
    
    var didCallFetchGroqResponse = false

    func fetchGroqResponse(payload: GroqRequest) async throws -> GroqResponse {
        didCallFetchGroqResponse = true
        
        if shouldThrowError {
            throw NSError(domain: "MockGroqRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated network error"])
        }
        
        if let response = mockResponse {
            return response
        } else {
            // Default mock response if none provided
            let message = GroqMessage(role: "assistant", content: "Mock response from Groq")
            let choice = GroqChoice(message: message)
            return GroqResponse(choices: [choice])
        }
    }
}
