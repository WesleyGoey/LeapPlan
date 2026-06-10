import Foundation

protocol GroqServiceProtocol {
    // MARK: - Send Message
    func sendMessage(chatHistory: [ChatMessage]) async throws -> String
}