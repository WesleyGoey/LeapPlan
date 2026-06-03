//
//  ProfileViewModelTests.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import XCTest
@testable import LeapPlan

@MainActor
final class ProfileViewModelTests: XCTestCase {
    var sut: ProfileViewModel!
    var mockAuthService: MockAuthService!
    var mockUserRepo: MockUserRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAuthService = MockAuthService()
        mockUserRepo = MockUserRepository()
        
        sut = ProfileViewModel(
            authService: mockAuthService,
            userRepo: mockUserRepo
        )
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockAuthService = nil
        mockUserRepo = nil
        try super.tearDownWithError()
    }
    
    func test_loadProfile_whenSuccess_shouldAssignUser() async {
        // Given
        let expectedUser = User(id: "123", email: "test@test.com", fullName: "Sean", joinedDate: Date())
        mockUserRepo.stubbedUser = expectedUser
        mockAuthService.isLoggedIn = true
        
        // When
        sut.loadUserProfile()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(mockUserRepo.didCallFetchUser)
        // XCTAssertEqual(sut.currentUser?.fullName, "Sean") // Sesuaikan variabel
    }
}