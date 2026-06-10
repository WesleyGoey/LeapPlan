//
//  AuthServiceProtocol.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Foundation

protocol AuthServiceProtocol {
    var isLoggedIn: Bool { get }

    // MARK: - Register
    func register(email: String, password: String) async throws -> String
    // MARK: - Login
    func login(email: String, password: String) async throws -> String
    // MARK: - Get Current User Id
    func getCurrentUserID() -> String?
    // MARK: - Logout
    func logout() throws
    // MARK: - Update Email
    func updateEmail(currentPassword: String, newEmail: String) async throws
    // MARK: - Update Password
    func updatePassword(currentPassword: String, newPassword: String)
        async throws
    // MARK: - Delete User
    func deleteUser(password: String) async throws
}
