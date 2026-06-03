//
//  MockAuthRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation
@testable import LeapPlan

class MockAuthRepository: AuthRepositoryProtocol {
    var shouldThrowError = false
    var mockUser: User?
    
    var didCallSaveUser = false
    var didCallFetchUser = false
    var didCallUpdateUser = false
    var didCallDeleteUser = false
    var lastFetchedUserID: String?
    
    enum MockError: Error {
        case simulatedNetworkError
        case userNotFound
    }
    
    func saveUser(_ user: User) async throws {
        didCallSaveUser = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        self.mockUser = user
    }
    
    func fetchUser(userID: String) async throws -> User {
        didCallFetchUser = true
        lastFetchedUserID = userID
        
        if shouldThrowError { throw MockError.simulatedNetworkError }
        
        guard let user = mockUser else {
            throw MockError.userNotFound
        }
        return user
    }
    
    func updateUser(_ user: User) async throws {
        didCallUpdateUser = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        self.mockUser = user
    }
    
    func deleteUser(userID: String) async throws {
        didCallDeleteUser = true
        if shouldThrowError { throw MockError.simulatedNetworkError }
        self.mockUser = nil
    }
}
