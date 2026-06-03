//
//  MockAuthService.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import Combine
import Foundation

@testable import LeapPlan

class MockAuthService: AuthServiceProtocol {

    @Published var isLoggedIn: Bool = false

    var shouldThrowError = false
    var currentUserIDToReturn: String? = "user_123"

    var didCallLogin = false
    var didCallRegister = false
    var didCallLogout = false
    var didCallUpdateEmail = false

    enum MockError: Error {
        case simulatedAuthError
    }

    func register(email: String, password: String) async throws -> String {
        didCallRegister = true
        if shouldThrowError { throw MockError.simulatedAuthError }
        isLoggedIn = true
        return "new_user_id"
    }

    func login(email: String, password: String) async throws -> String {
        didCallLogin = true
        if shouldThrowError { throw MockError.simulatedAuthError }
        isLoggedIn = true
        return currentUserIDToReturn ?? "default_id"
    }

    func getCurrentUserID() -> String? {
        return currentUserIDToReturn
    }

    func logout() throws {
        didCallLogout = true
        if shouldThrowError { throw MockError.simulatedAuthError }
        isLoggedIn = false
        currentUserIDToReturn = nil
    }

    func updateEmail(currentPassword: String, newEmail: String) async throws {
        didCallUpdateEmail = true
        if shouldThrowError { throw MockError.simulatedAuthError }
    }

    func updatePassword(currentPassword: String, newPassword: String)
        async throws
    {
        if shouldThrowError { throw MockError.simulatedAuthError }
    }

    func deleteUser(password: String) async throws {
        if shouldThrowError { throw MockError.simulatedAuthError }
        isLoggedIn = false
    }
}
