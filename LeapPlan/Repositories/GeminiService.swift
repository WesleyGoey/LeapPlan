import Foundation

class GeminiService: GeminiServiceProtocol {
    
    func sendMessage(chatHistory: [ChatMessage]) async throws -> String {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Restrict otak AI biar fokus ke travel aja
        let systemPromptText = "Kamu adalah LeapBot, asisten travel cerdas untuk aplikasi LeapPlan. Tugasmu HANYA membantu merencanakan liburan, membuat itinerary, dan merekomendasikan destinasi wisata. Jika pengguna bertanya coding, matematika, atau topik di luar travel dan liburan, TOLAK DENGAN SOPAN dan ingatkan bahwa kamu adalah asisten travel LeapPlan."
        let sysInstruction = SystemInstruction(parts: [GeminiPart(text: systemPromptText)])
        
        // Mapping format chat kita ke format yang diminta Google
        let geminiContents = chatHistory.map { msg in
            GeminiContent(role: msg.role, parts: [GeminiPart(text: msg.content)])
        }
        
        let payload = GeminiRequest(system_instruction: sysInstruction, contents: geminiContents)
        request.httpBody = try JSONEncoder().encode(payload)
        
        // Nembak API pakai native concurrency
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Parsing hasil balasan dari JSON ke Swift Struct
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        if let replyText = geminiResponse.candidates?.first?.content?.parts.first?.text {
            return replyText
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
}