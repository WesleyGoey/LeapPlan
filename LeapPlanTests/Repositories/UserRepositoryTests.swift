//
//  UserRepositoryTests.swift
//  LeapPlan
//
//  Created by student on 28/05/26.
//

import XCTest
@testable import LeapPlan

final class UserRepositoryTests: XCTestCase {
    var mockRepo: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockUserRepository()
    }

    override func tearDown() {
        mockRepo = nil
        super.tearDown()
    }

    func testFetchUserSuccess() async throws {
        let expectedUser = User(id: "123", email: "test@student.ciputra.ac.id", fullName: "Jason Christopher", joinedDate: Date())
        mockRepo.mockUser = expectedUser

        let user = try await mockRepo.fetchUser(userID: "123")
        
        XCTAssertEqual(user.id, "123")
        XCTAssertEqual(user.fullName, "Jason Christopher")
    }

    func testFetchUserFailure() async {
        mockRepo.shouldReturnError = true
        
        do {
            _ = try await mockRepo.fetchUser(userID: "123")
            XCTFail("Expected fetchUser to throw an error, but it succeeded.")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testSaveUserSuccess() async throws {
        let newUser = User(id: "456", email: "new@student.ciputra.ac.id", fullName: "New User", joinedDate: Date())
        
        try await mockRepo.saveUser(newUser)
        
        XCTAssertEqual(mockRepo.mockUser?.id, "456")
        XCTAssertEqual(mockRepo.mockUser?.email, "new@student.ciputra.ac.id")
    }
    
    func testUpdateUserSuccess() async throws {
        let updatedUser = User(id: "123", email: "updated@student.ciputra.ac.id", fullName: "Updated Name", joinedDate: Date())
        
        try await mockRepo.updateUser(updatedUser)
        
        XCTAssertEqual(mockRepo.mockUser?.fullName, "Updated Name")
    }
}
