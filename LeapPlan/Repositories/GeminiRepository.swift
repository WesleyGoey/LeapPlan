import Foundation

class GeminiRepository: GeminiRepositoryProtocol {
    private let apiKey = "TARUH_API_KEY_DI_SINI"
    
    func fetchGeminiResponse(payload: GeminiRequest) async throws -> GeminiResponse {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode data yang dikasih sama Service
        request.httpBody = try JSONEncoder().encode(payload)
        
        // Tembak API
        let (data, response) = try await URLSession.shared.data(for: request)
        
        //mknjdsafbsdfakjbas
        guard let httpResponse = response as? HTTPURLResponse, 
              (200...299).contains(httpResponse.statusCode) else {
            
            // Baca isi surat penolakan dari Google
            let serverMessage = String(data: data, encoding: .utf8) ?? "Nggak ada pesan"
            print("❌ GOOGLE API MENOLAK! Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            print("❌ ISI PESAN GOOGLE: \(serverMessage)")
            
            throw URLError(.badServerResponse)
        }
        //jkdcsgbasjdikfg
        
        // Balikin model utuh ke Service
        return try JSONDecoder().decode(GeminiResponse.self, from: data)
    }
}