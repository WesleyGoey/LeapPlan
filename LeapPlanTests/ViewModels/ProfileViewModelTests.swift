//
//  ProfileViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//

import XCTest

@testable import LeapPlan

@MainActor
final class ProfileViewModelTests: XCTestCase {

    var viewModel: ProfileViewModel!
    var mockAuthRepo: MockAuthRepository!
    var mockAuthService: MockAuthService!
    var mockFirestoreRepo: MockFirestoreRepository!

    override func setUp() {
        super.setUp()
        mockAuthRepo = MockAuthRepository()
        mockAuthService = MockAuthService()
        mockFirestoreRepo = MockFirestoreRepository()

        viewModel = ProfileViewModel(
            authRepo: mockAuthRepo,
            authService: mockAuthService,
            firestoreRepo: mockFirestoreRepo
        )
    }

    override func tearDown() {
        viewModel = nil
        mockAuthRepo = nil
        mockAuthService = nil
        mockFirestoreRepo = nil
        super.tearDown()
    }

    // MARK: - Test Cases

    func testLoadProfile_Success_CalculatesStats() async {
        // Arrange
        let user = User(
            id: "u1",
            email: "test@test.com",
            fullName: "Sean",
            profileImageUrl: nil,
            joinedDate: Date()
        )
        mockAuthRepo.mockUser = user
        mockAuthService.currentUserIDToReturn = "u1"

        let trip1 = Trip(
            id: "t1",
            title: "Trip 1",
            locationName: "Bali",
            startDate: Date(),
            endDate: Date(),
            status: .upcoming,
            participantIDs: [],
            createdAt: Date(),
            createdBy: "u1"
        )
        mockFirestoreRepo.mockTrips = ["u1": [trip1]]

        // Act
        viewModel.loadProfile()

        // Tunggu sebentar karena loadProfile menggunakan Task (asynchronous)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        XCTAssertEqual(viewModel.currentUser?.id, "u1")
        XCTAssertEqual(viewModel.totalTripsCount, 1)
        XCTAssertEqual(viewModel.upcomingTripsCount, 1)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLogin_Success() async {
        // Arrange
        viewModel.authEmail = "test@test.com"
        viewModel.authPassword = "password123"

        // Act
        let result = await viewModel.login()

        // Assert
        XCTAssertTrue(result)
        XCTAssertTrue(mockAuthService.didCallLogin)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testRegister_Success() async {
        // Arrange
        viewModel.authEmail = "new@test.com"
        viewModel.authPassword = "password123"
        viewModel.authFullName = "New User"

        // Act
        let result = await viewModel.register()

        // Assert
        XCTAssertTrue(result)
        XCTAssertTrue(mockAuthService.didCallRegister)
        XCTAssertTrue(mockAuthRepo.didCallSaveUser)
    }

    func testLogout_ResetsState() {
        // Arrange
        viewModel.totalTripsCount = 10

        // Act
        viewModel.logout()

        // Assert
        XCTAssertNil(viewModel.currentUser)
        XCTAssertEqual(viewModel.totalTripsCount, 0)
        XCTAssertTrue(mockAuthService.didCallLogout)
    }

    func testSaveEditedProfile_RequiresPasswordForEmailChange() async {
        // Arrange
        viewModel.currentUser = User(
            id: "u1",
            email: "old@test.com",
            fullName: "Old",
            profileImageUrl: nil,
            joinedDate: Date()
        )
        viewModel.editEmail = "new@test.com"  // Email diubah
        viewModel.currentPassword = ""  // Password dikosongkan (salah)

        // Act
        let result = await viewModel.saveEditedProfile(selectedImage: nil)

        // Assert
        XCTAssertFalse(result)
        XCTAssertNotNil(
            viewModel.errorMessage,
            "Harusnya error karena password kosong"
        )
    }

    func testSaveEditedProfile_Success() async {
        // Arrange
        let oldEmail = "old@test.com"
        viewModel.currentUser = User(
            id: "u1",
            email: oldEmail,
            fullName: "Old",
            profileImageUrl: nil,
            joinedDate: Date()
        )

        // PERBAIKAN: Set editEmail supaya tidak dianggap sedang ganti email
        viewModel.editEmail = oldEmail
        viewModel.editFullName = "New Name"

        // Act
        let result = await viewModel.saveEditedProfile(selectedImage: nil)

        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.currentUser?.fullName, "New Name")
        XCTAssertTrue(mockAuthRepo.didCallUpdateUser)
    }
}
