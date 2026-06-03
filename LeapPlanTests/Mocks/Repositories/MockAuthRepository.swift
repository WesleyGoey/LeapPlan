//
//  MockAuthRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation
@testable import LeapPlan

class MockAuthRepository: AuthRepositoryProtocol {
    // Variables to control the mock's behavior
    var shouldThrowError = false
    var mockUser: User?
    
    // Variables to verify interactions (Spies)
    var didCallSaveUser = false
    var didCallFetchUser = false
    var didCallUpdateUser = false
    var didCallDeleteUser = false
    var lastFetchedUserID: String?
    
    enum MockError: Error {
        case simulatedNetworkError
        case userNotFound
    }
    
    // MARK: - 1. CREATE
    func saveUser(_ user: User) async throws {
        didCallSaveUser = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        // Simulate saving by storing it locally in the mock
        self.mockUser = user
    }
    
    // MARK: - 2. READ
    func fetchUser(userID: String) async throws -> User {
        didCallFetchUser = true
        lastFetchedUserID = userID
        
        if shouldThrowError { throw MockError.simulatedNetworkError }
        
        guard let user = mockUser else {
            throw MockError.userNotFound
        }
        return user
    }
    
    // MARK: - 3. UPDATE
    func updateUser(_ user: User) async throws {
        didCallUpdateUser = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        self.mockUser = user
    }
    
    // MARK: - 4. DELETE
    func deleteUser(userID: String) async throws {
        didCallDeleteUser = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        self.mockUser = nil
    }
}
