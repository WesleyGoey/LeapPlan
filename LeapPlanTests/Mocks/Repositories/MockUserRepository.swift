//
//  MockUserRepository.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import Foundation
@testable import LeapPlan

class MockUserRepository: AuthRepositoryProtocol {
    var stubbedUser: User?
    var shouldThrowError = false
    var didCallFetchUser = false
    var didCallUpdateUser = false
    
    func fetchUserProfile(userID: String) async throws -> User {
        didCallFetchUser = true
        if shouldThrowError { throw URLError(.badServerResponse) }
        guard let user = stubbedUser else { throw URLError(.zeroByteResource) }
        return user
    }
    
    func updateUserProfile(_ user: User) async throws {
        didCallUpdateUser = true
        if shouldThrowError { throw URLError(.badServerResponse) }
    }
    
    // Sesuaikan jika ada fungsi auth lain di AuthRepositoryProtocol kamu
    func login(email: String, pass: String) async throws -> String { return "test_user_123" }
    func register(email: String, pass: String, name: String) async throws -> String { return "test_user_123" }
    func logout() throws {}
}