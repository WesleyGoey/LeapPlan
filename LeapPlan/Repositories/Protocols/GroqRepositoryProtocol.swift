//
//  GroqRepositoryProtocol.swift
//  LeapPlan
//
//  Created by student on 10/06/26.
//

import Foundation

protocol GroqRepositoryProtocol {
    // MARK: - Fetch Groq Response
    func fetchGroqResponse(payload: GroqRequest) async throws -> GroqResponse
}
