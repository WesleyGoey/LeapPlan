//
//  AuthService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import FirebaseAuth

class AuthService: AuthServiceProtocol {
    // MARK: - 1. CREATE
        func register(email: String, password: String) async throws -> String {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            return authResult.user.uid
        }
        
        // MARK: - 2. READ / AUTHENTICATE
        func login(email: String, password: String) async throws -> String {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            return authResult.user.uid
        }
        
        func getCurrentUserID() -> String? {
            return Auth.auth().currentUser?.uid
        }
        
        // MARK: - 3. UPDATE
        func updateEmail(currentPassword: String, newEmail: String) async throws {
            guard let user = Auth.auth().currentUser, let email = user.email else { return }
            
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            try await user.reauthenticate(with: credential)
            try await user.updateEmail(to: newEmail)
        }
        
        func updatePassword(currentPassword: String, newPassword: String) async throws {
            guard let user = Auth.auth().currentUser, let email = user.email else {
                throw NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Sesi tidak valid."])
            }
            
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
        }
        
        // MARK: - 4. DELETE
        func deleteUser(password: String) async throws {
            guard let user = Auth.auth().currentUser, let email = user.email else {
                throw NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Sesi tidak valid."])
            }
            
            // Wajib re-autentikasi sebelum menghapus akun secara permanen
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            try await user.reauthenticate(with: credential)
            try await user.delete()
        }
        
        // MARK: - 5. MISC
        func logout() throws {
            try Auth.auth().signOut()
        }
}
