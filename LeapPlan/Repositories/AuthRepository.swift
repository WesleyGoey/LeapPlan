//
//  AuthRepository.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import FirebaseFirestore
import Foundation

class AuthRepository: AuthRepositoryProtocol {
    private let db = Firestore.firestore()

    // MARK: - Save User
    func saveUser(_ user: User) async throws {
        guard let userID = user.id else { return }
        try db.collection("Users").document(userID).setData(from: user)
    }

    // MARK: - Fetch User
    func fetchUser(userID: String) async throws -> User {
        let doc = try await db.collection("Users").document(userID)
            .getDocument()
        guard let user = try? doc.data(as: User.self) else {
            throw NSError(
                domain: "AuthRepository",
                code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey: "Data profil tidak ditemukan"
                ]
            )
        }
        return user
    }

    // MARK: - Update User
    func updateUser(_ user: User) async throws {
        guard let userID = user.id else { return }
        try db.collection("Users").document(userID).setData(
            from: user,
            merge: true
        )
    }

    // MARK: - Delete User
    func deleteUser(userID: String) async throws {
        try await db.collection("Users").document(userID).delete()
    }
}
