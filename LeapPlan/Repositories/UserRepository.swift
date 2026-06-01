//
//  UserRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import FirebaseFirestore

class UserRepository: UserRepositoryProtocol {
    private let db = Firestore.firestore()
    
    // MARK: - 1. CREATE
    func saveUser(_ user: User) async throws {
        guard let userID = user.id else { return }
        try db.collection("Users").document(userID).setData(from: user)
    }
    
    // MARK: - 2. READ
    func fetchUser(userID: String) async throws -> User {
        let doc = try await db.collection("Users").document(userID).getDocument()
        guard let user = try? doc.data(as: User.self) else {
            throw NSError(domain: "UserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data profil tidak ditemukan"])
        }
        return user
    }
    
    // MARK: - 3. UPDATE
    func updateUser(_ user: User) async throws {
        guard let userID = user.id else { return }
        try db.collection("Users").document(userID).setData(from: user, merge: true)
    }
    
    // MARK: - 4. DELETE
    func deleteUser(userID: String) async throws {
        try await db.collection("Users").document(userID).delete()
    }
}
