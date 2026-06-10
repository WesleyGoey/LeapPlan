import Foundation

class GroqRepository: GroqRepositoryProtocol {
    private let apiKey = ""
    
    func fetchGroqResponse(payload: GroqRequest) async throws -> GroqResponse {
        let urlString = "https://api.groq.com/openai/v1/chat/completions"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Encode data yang dikasih sama Service
        request.httpBody = try JSONEncoder().encode(payload)
        
        // Tembak API
        let (data, response) = try await URLSession.shared.data(for: request)
        
        //mknjdsafbsdfakjbas
        guard let httpResponse = response as? HTTPURLResponse, 
              (200...299).contains(httpResponse.statusCode) else {
            
            // Baca isi surat penolakan
            let serverMessage = String(data: data, encoding: .utf8) ?? "Nggak ada pesan"
            print("❌ GROQ API MENOLAK! Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            print("❌ ISI PESAN GROQ: \(serverMessage)")
            
            throw URLError(.badServerResponse)
        }
        //jkdcsgbasjdikfg
        
        // Balikin model utuh ke Service
        return try JSONDecoder().decode(GroqResponse.self, from: data)
    }
}
