import Foundation

protocol GroqServiceProtocol {
    func sendMessage(chatHistory: [ChatMessage]) async throws -> String
}