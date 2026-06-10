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

    // MARK: - Test Load Profile
    func testLoadProfile() async {
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
            startDate: Date().addingTimeInterval(86400),
            endDate: Date().addingTimeInterval(86400 * 2),
            status: .upcoming,
            participantIDs: [],
            createdAt: Date(),
            createdBy: "u1"
        )
        mockFirestoreRepo.mockTrips = ["u1": [trip1]]

        viewModel.loadProfile()

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(viewModel.currentUser?.id, "u1")
        XCTAssertEqual(viewModel.totalTripsCount, 1)
        XCTAssertEqual(viewModel.upcomingTripsCount, 1)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Test Login & Register
    func testLogin() async {
        viewModel.authEmail = "test@test.com"
        viewModel.authPassword = "password123"

        let result = await viewModel.login()

        XCTAssertTrue(result)
        XCTAssertTrue(mockAuthService.didCallLogin)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Test Register
    func testRegister() async {
        viewModel.authEmail = "new@test.com"
        viewModel.authPassword = "password123"
        viewModel.authFullName = "New User"

        let result = await viewModel.register()

        XCTAssertTrue(result)
        XCTAssertTrue(mockAuthService.didCallRegister)
        XCTAssertTrue(mockAuthRepo.didCallSaveUser)
    }

    // MARK: - Test Logout
    func testLogout() {
        viewModel.totalTripsCount = 10

        viewModel.logout()

        XCTAssertNil(viewModel.currentUser)
        XCTAssertEqual(viewModel.totalTripsCount, 0)
        XCTAssertTrue(mockAuthService.didCallLogout)
    }

    // MARK: - Test Save Edited Profile if Email Changed but Password Empty
    func testSaveEditedProfile_RequiresPasswordForEmailChange() async {
        viewModel.currentUser = User(
            id: "u1",
            email: "old@test.com",
            fullName: "Old",
            profileImageUrl: nil,
            joinedDate: Date()
        )
        viewModel.editEmail = "new@test.com"
        viewModel.currentPassword = ""

        let result = await viewModel.saveEditedProfile(selectedImage: nil)

        XCTAssertFalse(result)
        XCTAssertNotNil(
            viewModel.errorMessage,
            "Harusnya error karena password kosong"
        )
    }

    // MARK: - Test Save Edited Profile Success
    func testSaveEditedProfile_Success() async {
        let oldEmail = "old@test.com"
        viewModel.currentUser = User(
            id: "u1",
            email: oldEmail,
            fullName: "Old",
            profileImageUrl: nil,
            joinedDate: Date()
        )

        viewModel.editEmail = oldEmail
        viewModel.editFullName = "New Name"

        let result = await viewModel.saveEditedProfile(selectedImage: nil)

        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.currentUser?.fullName, "New Name")
        XCTAssertTrue(mockAuthRepo.didCallUpdateUser)
    }
}
