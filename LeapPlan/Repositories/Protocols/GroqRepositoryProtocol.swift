import Foundation

protocol GroqRepositoryProtocol {
    // MARK: - Fetch Groq Response
    func fetchGroqResponse(payload: GroqRequest) async throws -> GroqResponse
}