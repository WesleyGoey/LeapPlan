//
//  MockAuthService.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Foundation
@testable import LeapPlan

class MockAuthService: AuthServiceProtocol {
    // Stubbed States
    var isLoggedIn: Bool = false
    var stubbedUserID: String? = "mock_user_123"
    var shouldThrowError = false
    
    // Spy Flags
    var didCallRegister = false
    var didCallLogin = false
    var didCallLogout = false
    var didCallUpdateEmail = false
    var didCallUpdatePassword = false
    var didCallDeleteUser = false

    func register(email: String, password: String) async throws -> String {
        didCallRegister = true
        if shouldThrowError { throw NSError(domain: "MockAuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Gagal Registrasi"]) }
        isLoggedIn = true
        return stubbedUserID ?? UUID().uuidString
    }
    
    func login(email: String, password: String) async throws -> String {
        didCallLogin = true
        if shouldThrowError { throw NSError(domain: "MockAuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Email atau Password Salah"]) }
        isLoggedIn = true
        return stubbedUserID ?? UUID().uuidString
    }
    
    func getCurrentUserID() -> String? {
        return stubbedUserID
    }
    
    func logout() throws {
        didCallLogout = true
        if shouldThrowError { throw NSError(domain: "MockAuthService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gagal Sign Out"]) }
        isLoggedIn = false
    }
    
    func updateEmail(currentPassword: String, newEmail: String) async throws {
        didCallUpdateEmail = true
        if shouldThrowError { throw NSError(domain: "MockAuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Password salah"]) }
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        didCallUpdatePassword = true
        if shouldThrowError { throw NSError(domain: "MockAuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Password saat ini tidak valid"]) }
    }
    
    func deleteUser(password: String) async throws {
        didCallDeleteUser = true
        if shouldThrowError { throw NSError(domain: "MockAuthService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gagal menghapus akun"]) }
        isLoggedIn = false
    }
}
