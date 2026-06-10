//
//  GroqServiceProtocol.swift
//  LeapPlan
//
//  Created by student on 10/06/26.
//

import Foundation

protocol GroqServiceProtocol {
    // MARK: - Send Message
    func sendMessage(chatHistory: [ChatMessage]) async throws -> String
}
