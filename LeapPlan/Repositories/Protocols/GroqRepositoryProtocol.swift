import Foundation

protocol GroqRepositoryProtocol {
    func fetchGroqResponse(payload: GroqRequest) async throws -> GroqResponse
}