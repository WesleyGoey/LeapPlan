import Foundation

class GeminiService: GeminiServiceProtocol {
    private let repository: GeminiRepositoryProtocol
    
    init(repository: GeminiRepositoryProtocol = GeminiRepository()) {
        self.repository = repository
    }
    
    func sendMessage(chatHistory: [ChatMessage]) async throws -> String {
        // Doktrin AI
        let systemPromptText = "Kamu adalah LeapBot, asisten travel cerdas untuk aplikasi LeapPlan. Tugasmu HANYA membantu merencanakan liburan, membuat itinerary, dan merekomendasikan destinasi wisata. Jika pengguna bertanya coding, matematika, atau topik di luar travel dan liburan, TOLAK DENGAN SOPAN dan ingatkan bahwa kamu adalah asisten travel LeapPlan."
        let sysInstruction = SystemInstruction(parts: [GeminiPart(text: systemPromptText)])
        
        // Mapping format
        let geminiContents = chatHistory.map { msg in
            GeminiContent(role: msg.role, parts: [GeminiPart(text: msg.content)])
        }
        
        let payload = GeminiRequest(system_instruction: sysInstruction, contents: geminiContents)
        
        // Eksekusi via Repository
        let geminiResponse = try await repository.fetchGeminiResponse(payload: payload)
        
        if let replyText = geminiResponse.candidates?.first?.content?.parts.first?.text {
            return replyText
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
}