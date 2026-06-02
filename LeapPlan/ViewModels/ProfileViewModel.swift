//
//  ProfileViewModel.swift
//  LeapPlan
//
//  Created by student on 28/05/26.
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let userRepository: UserRepositoryProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - PERBAIKAN INIT PROFILE VIEW MODEL
    init(userRepository: UserRepositoryProtocol? = nil, authService: AuthServiceProtocol? = nil) {
        // Jika tidak ada repository yang di-inject (misal saat running app asli), gunakan class default-nya
        self.userRepository = userRepository ?? UserRepository()
        self.authService = authService ?? AuthService()
    }
    
    func loadProfile() {
        guard let userID = authService.getCurrentUserID() else { return }
        isLoading = true
        
        Task {
            do {
                self.currentUser = try await userRepository.fetchUser(userID: userID)
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to load profile."
                self.isLoading = false
            }
        }
    }
    
    func logout() {
        do {
            try authService.logout()
            self.currentUser = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
