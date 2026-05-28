//
//  MockUserRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
@testable import LeapPlan

class MockUserRepository: UserRepositoryProtocol {
    var shouldReturnError = false
    var mockUser: User?
    
    func fetchUser(userID: String) async throws -> User {
        if shouldReturnError { throw URLError(.badServerResponse) }
        guard let user = mockUser else {
            throw NSError(domain: "MockError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return user
    }
    
    func saveUser(_ user: User) async throws {
        if shouldReturnError { throw URLError(.badServerResponse) }
        mockUser = user
    }
    
    func updateUser(_ user: User) async throws {
        if shouldReturnError { throw URLError(.badServerResponse) }
        mockUser = user
    }
}