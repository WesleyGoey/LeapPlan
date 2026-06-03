//
//  AuthService.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import Foundation
import FirebaseAuth
import Combine

class AuthService: ObservableObject, AuthServiceProtocol {
    @Published var isLoggedIn: Bool = false
    
    private let authRepo: AuthRepositoryProtocol
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init(authRepo: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepo = authRepo
        
        // REVISI: Listener ini memastikan semua ViewModel di tab manapun
        // akan langsung ter-update jika status Login Firebase berubah.
        self.authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isLoggedIn = (user != nil)
            }
        }
    }
    
    deinit {
        // Membersihkan listener saat service dihancurkan agar tidak memory leak
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func register(email: String, password: String) async throws -> String {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        // Set state login ke true
        DispatchQueue.main.async { self.isLoggedIn = true }
        return authResult.user.uid
    }
    
    func login(email: String, password: String) async throws -> String {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        DispatchQueue.main.async { self.isLoggedIn = true }
        return authResult.user.uid
    }
    
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func logout() throws {
        try Auth.auth().signOut()
        DispatchQueue.main.async { self.isLoggedIn = false }
    }
    
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
    
    func deleteUser(password: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Sesi tidak valid."])
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
        try await user.delete()
        DispatchQueue.main.async { self.isLoggedIn = false }
    }
}
