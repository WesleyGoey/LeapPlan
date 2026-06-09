import Foundation

protocol GeminiServiceProtocol {
    func sendMessage(chatHistory: [ChatMessage]) async throws -> String
}