//
//  MockFourSquareService.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import Foundation
@testable import LeapPlan

class MockFourSquareService: FourSquareServiceProtocol {
    var stubbedAutocompleteResults: [FSQResponse] = []
    var shouldThrowError: Bool = false
    
    func autocompleteLocation(query: String) async throws -> [FSQResponse] {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
        return stubbedAutocompleteResults
    }
}