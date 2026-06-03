//
//  MockFourSquareRepository.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import Foundation
@testable import LeapPlan

class MockFourSquareRepository: FourSquareRepositoryProtocol {
    var stubbedPlaces: [FSQResponse] = []
    var shouldThrowError = false
    var didCallSearchPlaces = false
    
    func searchPlaces(query: String, near location: String) async throws -> [FSQResponse] {
        didCallSearchPlaces = true
        if shouldThrowError { throw URLError(.badServerResponse) }
        return stubbedPlaces
    }
}