import Foundation

protocol GeminiRepositoryProtocol {
    func fetchGeminiResponse(payload: GeminiRequest) async throws -> GeminiResponse
}