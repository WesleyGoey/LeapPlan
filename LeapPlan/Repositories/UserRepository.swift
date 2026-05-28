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
    
    func fetchUser(userID: String) async throws -> User {
        let doc = try await db.collection("Users").document(userID).getDocument()
        guard let user = try? doc.data(as: User.self) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return user
    }
    
    func saveUser(_ user: User) async throws {
        guard let userID = user.id else { return }
        try db.collection("Users").document(userID).setData(from: user)
    }
    
    func updateUser(_ user: User) async throws {
        guard let userID = user.id else { return }
        try db.collection("Users").document(userID).setData(from: user, merge: true)
    }
}