//
//  ProfileViewModel.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - TRAVEL STATS (Konek Backend Firestore)
    @Published var totalTripsCount: Int = 0
    @Published var upcomingTripsCount: Int = 0

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
    private let firestoreRepo: FirestoreRepositoryProtocol  // Tambahan buat narik data trip

    init(
        authRepo: AuthRepositoryProtocol? = nil,
        authService: AuthServiceProtocol? = nil,
        firestoreRepo: FirestoreRepositoryProtocol? = nil
    ) {
        self.authRepo = authRepo ?? AuthRepository()
        self.authService = authService ?? AuthService()
        self.firestoreRepo = firestoreRepo ?? FirestoreRepository()
    }

    var isLoggedIn: Bool { return authService.isLoggedIn }

    func loadProfile() {
        guard let userID = authService.getCurrentUserID() else { return }
        isLoading = true
        Task {
            do {
                self.currentUser = try await authRepo.fetchUser(userID: userID)

                // MENGHITUNG STATISTIK TRIP DARI FIREBASE
                let userTrips = try await firestoreRepo.fetchTrips(
                    forUserID: userID
                )
                self.totalTripsCount = userTrips.count
                self.upcomingTripsCount =
                    userTrips.filter {
                        $0.status == .upcoming || $0.status == .ongoing
                    }.count

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
        authEmail = ""
        authPassword = ""
        authFullName = ""
        errorMessage = nil
    }

    func login() async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.login(
                email: authEmail,
                password: authPassword
            )
            loadProfile()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func register() async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            let uid = try await authService.register(
                email: authEmail,
                password: authPassword
            )

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
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func logout() {
        do {
            try authService.logout()
            self.currentUser = nil
            self.totalTripsCount = 0
            self.upcomingTripsCount = 0

            NotificationCenter.default.post(
                name: NSNotification.Name("UserLoggedOut"),
                object: nil
            )

            clearAuthForm()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func saveEditedProfile(selectedImage: UIImage?) async -> Bool {
        guard var updatedUser = currentUser else { return false }
        isLoading = true
        errorMessage = nil

        do {
            if let img = selectedImage {
                updatedUser.profileImageUrl = Base64Helper.encode(img)
            } else {
                updatedUser.profileImageUrl = editProfileImageBase64
            }

            if editEmail != updatedUser.email || !editPassword.isEmpty {
                guard !currentPassword.isEmpty else {
                    errorMessage =
                        "Current password is required to change email or password."
                    isLoading = false
                    return false
                }
                if editEmail != updatedUser.email {
                    try await authService.updateEmail(
                        currentPassword: currentPassword,
                        newEmail: editEmail
                    )
                    updatedUser.email = editEmail
                }
                if !editPassword.isEmpty {
                    try await authService.updatePassword(
                        currentPassword: currentPassword,
                        newPassword: editPassword
                    )
                }
            }

            updatedUser.fullName = editFullName
            try await authRepo.updateUser(updatedUser)

            self.currentUser = updatedUser
            isLoading = false
            return true

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
