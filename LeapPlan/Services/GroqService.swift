import Foundation

class GroqService: GroqServiceProtocol {
    private let repository: GroqRepositoryProtocol
    
    init(repository: GroqRepositoryProtocol = GroqRepository()) {
        self.repository = repository
    }
    
    // MARK: - Send Message
    func sendMessage(chatHistory: [ChatMessage]) async throws -> String {
        let systemPromptText = "Kamu adalah LeapBot, asisten travel cerdas untuk aplikasi LeapPlan. Tugasmu HANYA membantu merencanakan liburan, membuat itinerary, dan merekomendasikan destinasi wisata. Jika pengguna bertanya coding, matematika, atau topik di luar travel dan liburan, TOLAK DENGAN SOPAN dan ingatkan bahwa kamu adalah asisten travel LeapPlan."
        let systemMessage = GroqMessage(role: "system", content: systemPromptText)
        
        let groqMessages: [GroqMessage] = chatHistory.map { msg in
            let role = msg.role == "model" ? "assistant" : msg.role
            return GroqMessage(role: role, content: msg.content)
        }
        
        var allMessages = [systemMessage]
        allMessages.append(contentsOf: groqMessages)
        
        let payload = GroqRequest(model: "llama-3.3-70b-versatile", messages: allMessages)
        
        let groqResponse = try await repository.fetchGroqResponse(payload: payload)
        
        if let replyText = groqResponse.choices?.first?.message?.content {
            return replyText
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
}
