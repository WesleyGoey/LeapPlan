//
//  AuthServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

protocol AuthServiceProtocol {
    var isLoggedIn: Bool { get }
    
    func register(email: String, password: String) async throws -> String
    func login(email: String, password: String) async throws -> String
    func getCurrentUserID() -> String?
    func logout() throws
    func updateEmail(currentPassword: String, newEmail: String) async throws
    func updatePassword(currentPassword: String, newPassword: String) async throws
    func deleteUser(password: String) async throws
}
