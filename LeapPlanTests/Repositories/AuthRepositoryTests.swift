//
//  AuthRepositoryTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import FirebaseFirestore
import XCTest

@testable import LeapPlan

@MainActor
final class AuthRepositoryTests: XCTestCase {

    var repo: AuthRepository!
    let testUserID = "test_user_id_999"

    override func setUp() {
        super.setUp()
        repo = AuthRepository()
    }

    override func tearDown() async throws {
        let db = Firestore.firestore()
        try? await db.collection("Users").document(testUserID).delete()
        repo = nil
        try await super.tearDown()
    }

    private func createDummyUser() -> User {
        return User(
            id: testUserID,
            email: "test@leapplan.com",
            fullName: "Test User",
            profileImageUrl: nil,
            joinedDate: Date()
        )
    }

    // MARK: - Test Create and Fetch
    func testSaveAndFetchUser_ShouldSucceed() async throws {
        let user = createDummyUser()

        try await repo.saveUser(user)

        let fetchedUser = try await repo.fetchUser(userID: testUserID)

        XCTAssertEqual(fetchedUser.id, user.id)
        XCTAssertEqual(fetchedUser.fullName, "Test User")
    }

    // MARK: - Test Update User
    func testUpdateUser_ShouldUpdateFullName() async throws {
        let user = createDummyUser()
        try await repo.saveUser(user)

        var updatedUser = user
        updatedUser.fullName = "Updated Name"
        try await repo.updateUser(updatedUser)

        let fetchedUser = try await repo.fetchUser(userID: testUserID)

        XCTAssertEqual(fetchedUser.fullName, "Updated Name")
    }

    func testDeleteUser_ShouldRemoveFromDatabase() async throws {
        let user = createDummyUser()
        try await repo.saveUser(user)

        try await repo.deleteUser(userID: testUserID)

        do {
            _ = try await repo.fetchUser(userID: testUserID)
            XCTFail("Seharusnya fetchUser melempar error setelah user dihapus")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Test Fetch Non-Existent User
    func testFetchNonExistentUser_ShouldThrowError() async {
        do {
            _ = try await repo.fetchUser(userID: "non_existent_id")
            XCTFail("Seharusnya gagal karena user tidak ada")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 404, "Harus error code 404")
        }
    }
}
