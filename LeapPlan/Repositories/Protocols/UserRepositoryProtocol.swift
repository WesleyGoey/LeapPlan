//
//  UserRepositoryProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

protocol UserRepositoryProtocol {
    // 1. CREATE
        func saveUser(_ user: User) async throws
        
        // 2. READ
        func fetchUser(userID: String) async throws -> User
        
        // 3. UPDATE
        func updateUser(_ user: User) async throws
        
        // 4. DELETE
        func deleteUser(userID: String) async throws
}
