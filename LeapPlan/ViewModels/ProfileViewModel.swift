//
//  ProfileViewModel.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var authEmail = ""
    @Published var authPassword = ""
    @Published var authFullName = ""
    
    @Published var editFullName = ""
    @Published var editEmail = ""
    @Published var editPassword = ""
    @Published var currentPassword = ""
    @Published var editProfileImageBase64: String? = nil
    
    private let authRepo: AuthRepositoryProtocol
    private let authService: AuthServiceProtocol
    
    init(authRepo: AuthRepositoryProtocol? = nil, authService: AuthServiceProtocol? = nil) {
        self.authRepo = authRepo ?? AuthRepository()
        self.authService = authService ?? AuthService()
    }
    
    var isLoggedIn: Bool { return authService.isLoggedIn }
    
    func loadProfile() {
        guard let userID = authService.getCurrentUserID() else { return }
        isLoading = true
        Task {
            do {
                self.currentUser = try await authRepo.fetchUser(userID: userID)
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to load profile."
                self.isLoading = false
            }
        }
    }
    
    func populateEditForm() {
        guard let user = currentUser else { return }
        editFullName = user.fullName
        editEmail = user.email
        editProfileImageBase64 = user.profileImageUrl
        editPassword = ""
        currentPassword = ""
    }
    
    func clearAuthForm() {
        authEmail = ""; authPassword = ""; authFullName = ""; errorMessage = nil
    }
    
    func login() async -> Bool {
        isLoading = true; errorMessage = nil
        do {
            _ = try await authService.login(email: authEmail, password: authPassword)
            loadProfile()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription; isLoading = false
            return false
        }
    }
    
    func register() async -> Bool {
        isLoading = true; errorMessage = nil
        do {
            let uid = try await authService.register(email: authEmail, password: authPassword)
            
            // Perbaikan: tambahkan argumen joinedDate: Date()
            let newUser = User(
                id: uid,
                email: authEmail,
                fullName: authFullName,
                profileImageUrl: nil,
                joinedDate: Date()
            )
            
            try await authRepo.saveUser(newUser)
            loadProfile()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription; isLoading = false
            return false
        }
    }
    
    func logout() {
        do {
            try authService.logout()
            self.currentUser = nil
            clearAuthForm()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func saveEditedProfile(selectedImage: UIImage?) async -> Bool {
        guard var updatedUser = currentUser else { return false }
        isLoading = true; errorMessage = nil
        
        do {
            // MENGGUNAKAN BASE64 HELPER EKSKLUSIF
            if let img = selectedImage {
                updatedUser.profileImageUrl = Base64Helper.encode(img)
            } else {
                updatedUser.profileImageUrl = editProfileImageBase64
            }
            
            if editEmail != updatedUser.email || !editPassword.isEmpty {
                guard !currentPassword.isEmpty else {
                    errorMessage = "Current password is required to change email or password."
                    isLoading = false; return false
                }
                if editEmail != updatedUser.email {
                    try await authService.updateEmail(currentPassword: currentPassword, newEmail: editEmail)
                    updatedUser.email = editEmail
                }
                if !editPassword.isEmpty {
                    try await authService.updatePassword(currentPassword: currentPassword, newPassword: editPassword)
                }
            }
            
            updatedUser.fullName = editFullName
            try await authRepo.updateUser(updatedUser)
            
            self.currentUser = updatedUser
            isLoading = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription; isLoading = false
            return false
        }
    }
}
