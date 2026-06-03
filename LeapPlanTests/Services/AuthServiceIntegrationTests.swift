//
//  MockFirebaseAuthProvider.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import FirebaseAuth
import XCTest

@testable import LeapPlan

final class AuthServiceIntegrationTests: XCTestCase {

    var authService: AuthService!
    var mockAuthRepo: MockAuthRepository!

    override func setUp() {
        super.setUp()

        mockAuthRepo = MockAuthRepository()

        authService = AuthService(authRepo: mockAuthRepo)
    }

    override func tearDown() {
        try? Auth.auth().signOut()

        authService = nil
        mockAuthRepo = nil
        super.tearDown()
    }

    // MARK: - Test Login With Invalid Credentials
    func testLogin_WithInvalidCredentials_ShouldFail() async {
        let fakeEmail = "user_ngasal_123@leapplan.com"
        let fakePassword = "wrongpassword"

        do {
            _ = try await authService.login(
                email: fakeEmail,
                password: fakePassword
            )
            XCTFail(
                "Test harusnya gagal dan masuk ke block catch, karena akun tidak ada di Firebase."
            )
        } catch {
            let isLoggedIn = await MainActor.run { authService.isLoggedIn }
            XCTAssertFalse(
                isLoggedIn,
                "State isLoggedIn harus tetap false jika login gagal."
            )
        }
    }

    // MARK: - Test Login With Valid Credentials
    func testLogin() async throws {
        let validEmail = "sean@gmail.com"
        let validPassword = "12345678"

        let uid = try await authService.login(
            email: validEmail,
            password: validPassword
        )

        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertNotNil(uid, "UID tidak boleh kosong dari Firebase.")
        let isLoggedInAfterLogin = await MainActor.run { authService.isLoggedIn }
        XCTAssertTrue(
            isLoggedInAfterLogin,
            "State isLoggedIn harus berubah menjadi true setelah login berhasil."
        )
        let currentUID = await MainActor.run { authService.getCurrentUserID() }
        XCTAssertEqual(
            currentUID,
            uid,
            "UID yang direturn harus sama dengan CurrentUserID."
        )

        try await authService.logout()

        try await Task.sleep(nanoseconds: 500_000_000)
        let isLoggedInAfterLogout = await MainActor.run { authService.isLoggedIn }
        XCTAssertFalse(
            isLoggedInAfterLogout,
            "State isLoggedIn harus kembali false setelah logout."
        )
    }

    // MARK: - Test Logout
    func testLogout() async throws {
        let validEmail = "sean@gmail.com"
        let validPassword = "12345678"
        _ = try await authService.login(
            email: validEmail,
            password: validPassword
        )
        try await Task.sleep(nanoseconds: 500_000_000)
        let isLoggedInPreLogout = await MainActor.run { authService.isLoggedIn }
        XCTAssertTrue(
            isLoggedInPreLogout,
            "Harus login terlebih dahulu sebelum bisa test logout"
        )

        try await authService.logout()
        try await Task.sleep(nanoseconds: 500_000_000)

        let isLoggedInPostLogout = await MainActor.run { authService.isLoggedIn }
        XCTAssertFalse(
            isLoggedInPostLogout,
            "isLoggedIn harus bernilai false"
        )
        let currentUIDAfterLogout = await MainActor.run { authService.getCurrentUserID() }
        XCTAssertNil(
            currentUIDAfterLogout,
            "Current UID harus kosong setelah logout"
        )
    }

    // MARK: - Test Register, Update Password, and Delete User
    func test_Register_Update_Delete() async throws {
        let randomString = UUID().uuidString.prefix(8)
        let randomEmail = "user_\(randomString)@leapplan.com"
        let initialPassword = "password123"
        let updatedPassword = "newpassword123"

        let uid = try await authService.register(
            email: randomEmail,
            password: initialPassword
        )
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertNotNil(uid, "Register harus mengembalikan UID yang valid")
        let isLoggedInAfterRegister = await MainActor.run { authService.isLoggedIn }
        XCTAssertTrue(
            isLoggedInAfterRegister,
            "isLoggedIn harus true setelah register"
        )

        try await authService.updatePassword(
            currentPassword: initialPassword,
            newPassword: updatedPassword
        )
        try await Task.sleep(nanoseconds: 500_000_000)

        try await authService.deleteUser(password: updatedPassword)
        try await Task.sleep(nanoseconds: 500_000_000)

        let isLoggedInAfterDelete = await MainActor.run { authService.isLoggedIn }
        XCTAssertFalse(
            isLoggedInAfterDelete,
            "State isLoggedIn harus kembali false setelah user dihapus"
        )
        let currentUIDAfterDelete = await MainActor.run { authService.getCurrentUserID() }
        XCTAssertNil(
            currentUIDAfterDelete,
            "UID harus nil karena user sudah tidak ada di database"
        )
    }
}

