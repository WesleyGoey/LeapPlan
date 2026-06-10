import Foundation

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let role: String
    let content: String
}

struct GroqRequest: Codable {
    let model: String
    let messages: [GroqMessage]
}

struct GroqMessage: Codable {
    let role: String
    let content: String
}

struct GroqResponse: Codable {
    let choices: [GroqChoice]?
}

struct GroqChoice: Codable {
    let message: GroqMessage?
}
