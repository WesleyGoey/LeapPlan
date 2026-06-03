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
    var mockAuthRepo: MockAuthRepository!  // Kita pakai mock untuk repo agar tidak menyimpan data ke Firestore asli

    override func setUp() {
        super.setUp()

        // 1. Inisialisasi Mock Repository
        mockAuthRepo = MockAuthRepository()

        // 2. Inisialisasi AuthService ASLI tanpa mengubah kodenya
        // Kita inject mockAuthRepo agar kalaupun ada operasi database, dia tidak nyasar ke database asli
        authService = AuthService(authRepo: mockAuthRepo)
    }

    override func tearDown() {
        // Logout jika masih ada sisa sesi dari test sebelumnya
        try? Auth.auth().signOut()

        authService = nil
        mockAuthRepo = nil
        super.tearDown()
    }

    // MARK: - Test 1: Skenario Gagal (Paling Aman)
    func testLogin_WithInvalidCredentials_ShouldFail() async {
        // Arrange
        let fakeEmail = "user_ngasal_123@leapplan.com"
        let fakePassword = "wrongpassword"

        // Act & Assert
        do {
            _ = try await authService.login(
                email: fakeEmail,
                password: fakePassword
            )
            XCTFail(
                "Test harusnya gagal dan masuk ke block catch, karena akun tidak ada di Firebase."
            )
        } catch {
            // Karena error, kita pastikan state isLoggedIn tetap false
            XCTAssertFalse(
                authService.isLoggedIn,
                "State isLoggedIn harus tetap false jika login gagal."
            )
        }
    }

    // MARK: - Test 2: Skenario Sukses (Butuh Akun Asli di Firebase)
    func testLogin() async throws {
        // Arrange
        // PENTING: Anda harus membuat akun ini secara manual di Firebase Console Anda
        let validEmail = "sean@gmail.com"
        let validPassword = "12345678"

        // Act
        let uid = try await authService.login(
            email: validEmail,
            password: validPassword
        )

        // Beri jeda 0.5 detik karena listener Auth.auth().addStateDidChangeListener
        // di AuthService berjalan secara asynchronous di Main Thread
        try await Task.sleep(nanoseconds: 500_000_000)

        // Assert
        XCTAssertNotNil(uid, "UID tidak boleh kosong dari Firebase.")
        XCTAssertTrue(
            authService.isLoggedIn,
            "State isLoggedIn harus berubah menjadi true setelah login berhasil."
        )
        XCTAssertEqual(
            authService.getCurrentUserID(),
            uid,
            "UID yang direturn harus sama dengan CurrentUserID."
        )

        // Clean Up (Logout agar tidak mengganggu test lain)
        try authService.logout()

        // Tunggu sebentar untuk proses logout
        try await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertFalse(
            authService.isLoggedIn,
            "State isLoggedIn harus kembali false setelah logout."
        )
    }

    // MARK: - Test 3: Uji Logout secara Eksplisit
    func testLogout() async throws {
        // Arrange: Login terlebih dahulu
        let validEmail = "sean@gmail.com"
        let validPassword = "12345678"
        _ = try await authService.login(
            email: validEmail,
            password: validPassword
        )
        try await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertTrue(
            authService.isLoggedIn,
            "Harus login terlebih dahulu sebelum bisa test logout"
        )

        // Act: Lakukan Logout
        try authService.logout()
        try await Task.sleep(nanoseconds: 500_000_000)

        // Assert: Pastikan semuanya bersih
        XCTAssertFalse(
            authService.isLoggedIn,
            "isLoggedIn harus bernilai false"
        )
        XCTAssertNil(
            authService.getCurrentUserID(),
            "Current UID harus kosong setelah logout"
        )
    }

    // MARK: - Test 4: Uji Siklus Penuh (Register -> Update Password -> Delete)
    // Test ini akan membuat akun random, mengujinya, lalu menghapusnya agar database tetap bersih.
    func test_Register_Update_Delete() async throws {
        // 1. Arrange (Siapkan Email & Password Acak)
        let randomString = UUID().uuidString.prefix(8)
        let randomEmail = "user_\(randomString)@leapplan.com"
        let initialPassword = "password123"
        let updatedPassword = "newpassword123"

        // ==========================================
        // ACT & ASSERT 1: REGISTER
        // ==========================================
        let uid = try await authService.register(
            email: randomEmail,
            password: initialPassword
        )
        try await Task.sleep(nanoseconds: 500_000_000)  // Tunggu sinkronisasi

        XCTAssertNotNil(uid, "Register harus mengembalikan UID yang valid")
        XCTAssertTrue(
            authService.isLoggedIn,
            "isLoggedIn harus true setelah register"
        )

        try await authService.updatePassword(
            currentPassword: initialPassword,
            newPassword: updatedPassword
        )
        try await Task.sleep(nanoseconds: 500_000_000)

        try await authService.deleteUser(password: updatedPassword)
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertFalse(
            authService.isLoggedIn,
            "State isLoggedIn harus kembali false setelah user dihapus"
        )
        XCTAssertNil(
            authService.getCurrentUserID(),
            "UID harus nil karena user sudah tidak ada di database"
        )
    }
}
