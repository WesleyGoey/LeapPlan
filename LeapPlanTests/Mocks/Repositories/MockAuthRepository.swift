//
//  MockAuthRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import Foundation
@testable import LeapPlan

class MockAuthRepository: AuthRepositoryProtocol {
    // Simulasi database lokal (Dictionary)
    var users: [String: User] = [:]
    
    // Flag untuk mensimulasikan error (untuk ngetes handling error di ViewModel)
    var shouldThrowError = false
    
    func saveUser(_ user: User) async throws {
        if shouldThrowError { throw NSError(domain: "MockAuth", code: 500) }
        guard let userID = user.id else { return }
        users[userID] = user
    }
    
    func fetchUser(userID: String) async throws -> User {
        if shouldThrowError { throw NSError(domain: "MockAuth", code: 500) }
        
        guard let user = users[userID] else {
            throw NSError(domain: "MockAuth", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return user
    }
    
    func updateUser(_ user: User) async throws {
        if shouldThrowError { throw NSError(domain: "MockAuth", code: 500) }
        guard let userID = user.id else { return }
        users[userID] = user
    }
    
    func deleteUser(userID: String) async throws {
        if shouldThrowError { throw NSError(domain: "MockAuth", code: 500) }
        users.removeValue(forKey: userID)
    }
}
