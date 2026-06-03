//
//  AuthRepositoryTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import FirebaseFirestore
import XCTest

@testable import LeapPlan

final class AuthRepositoryTests: XCTestCase {

    var repo: AuthRepository!
    let testUserID = "test_user_id_999"

    override func setUp() {
        super.setUp()
        repo = AuthRepository()
    }

    override func tearDown() {
        // Cleanup: Selalu hapus user dummy setelah setiap test selesai
        let db = Firestore.firestore()
        let _ = try? db.collection("Users").document(testUserID).delete()
        repo = nil
        super.tearDown()
    }

    // MARK: - Helper User
    private func createDummyUser() -> User {
        return User(
            id: testUserID,
            email: "test@leapplan.com",
            fullName: "Test User",
            profileImageUrl: nil,
            joinedDate: Date()
        )
    }

    // MARK: - 1. Test Save & Fetch
    func testSaveAndFetchUser_ShouldSucceed() async throws {
        // Arrange
        let user = createDummyUser()

        // Act (Save)
        try await repo.saveUser(user)

        // Act (Fetch)
        let fetchedUser = try await repo.fetchUser(userID: testUserID)

        // Assert
        XCTAssertEqual(fetchedUser.id, user.id)
        XCTAssertEqual(fetchedUser.fullName, "Test User")
    }

    // MARK: - 2. Test Update
    func testUpdateUser_ShouldUpdateFullName() async throws {
        // Arrange
        let user = createDummyUser()
        try await repo.saveUser(user)

        // Act
        var updatedUser = user
        updatedUser.fullName = "Updated Name"
        try await repo.updateUser(updatedUser)

        let fetchedUser = try await repo.fetchUser(userID: testUserID)

        // Assert
        XCTAssertEqual(fetchedUser.fullName, "Updated Name")
    }

    // MARK: - 3. Test Delete
    func testDeleteUser_ShouldRemoveFromDatabase() async throws {
        // Arrange
        let user = createDummyUser()
        try await repo.saveUser(user)

        // Act
        try await repo.deleteUser(userID: testUserID)

        // Assert & Act
        do {
            _ = try await repo.fetchUser(userID: testUserID)
            XCTFail("Seharusnya fetchUser melempar error setelah user dihapus")
        } catch {
            XCTAssertNotNil(error)  // Error 404 dari AuthRepository kita
        }
    }

    // MARK: - 4. Test Fetch Non-Existent User
    func testFetchNonExistentUser_ShouldThrowError() async {
        // Act & Assert
        do {
            _ = try await repo.fetchUser(userID: "non_existent_id")
            XCTFail("Seharusnya gagal karena user tidak ada")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 404, "Harus error code 404")
        }
    }
}
