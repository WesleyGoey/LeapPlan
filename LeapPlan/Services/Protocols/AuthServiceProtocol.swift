//
//  AuthServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

protocol AuthServiceProtocol {
    // 1. CREATE
    func register(email: String, password: String) async throws -> String
    
    // 2. READ / AUTHENTICATE
    func login(email: String, password: String) async throws -> String
    func getCurrentUserID() -> String?
    
    // 3. UPDATE
    func updateEmail(currentPassword: String, newEmail: String) async throws
    func updatePassword(currentPassword: String, newPassword: String) async throws
    
    // 4. DELETE
    func deleteUser(password: String) async throws
    
    // 5. MISC
    func logout() throws
}
