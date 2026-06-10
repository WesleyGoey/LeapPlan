import Foundation

// MARK: - Model untuk UI Chat
struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let role: String
    let content: String
}

// MARK: - Model untuk Request ke API Groq
struct GroqRequest: Codable {
    let model: String
    let messages: [GroqMessage]
}

struct GroqMessage: Codable {
    let role: String
    let content: String
}

// MARK: - Model untuk Response dari API Groq
struct GroqResponse: Codable {
    let choices: [GroqChoice]?
}

struct GroqChoice: Codable {
    let message: GroqMessage?
}
