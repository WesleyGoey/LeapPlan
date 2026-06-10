import Foundation

// MARK: - Model untuk UI Chat
struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let role: String // "user" atau "model"
    let content: String
}

// MARK: - Model untuk Request ke API Gemini
struct GeminiRequest: Codable {
    let systemInstruction: SystemInstruction?
    let contents: [GeminiContent]
}

struct SystemInstruction: Codable {
    let parts: [GeminiPart]
}

struct GeminiContent: Codable {
    let role: String
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

// MARK: - Model untuk Response dari API Gemini
struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
}

struct GeminiCandidate: Codable {
    let content: GeminiContent?
}
