//
//  AuthService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import FirebaseAuth // Pastikan import Firebase Auth

class AuthService: AuthServiceProtocol {
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
}