//
//  ProfileViewModelTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class ProfileViewModelTests: XCTestCase {
    
    private var mockAuthRepo: MockAuthRepository!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreRepo: MockFirestoreRepository!
    
    override func setUp() {
        super.setUp()
        mockAuthRepo = MockAuthRepository()
        mockAuthService = MockAuthService()
        mockFirestoreRepo = MockFirestoreRepository()
    }
    
    override func tearDown() {
        mockAuthRepo = nil
        mockAuthService = nil
        mockFirestoreRepo = nil
        super.tearDown()
    }
    
    @MainActor
    func testLoadProfile_CalculatesStatsCorrectly() async {
        // Arrange
        let userID = "user_sean"
        mockAuthService.stubbedUserID = userID
        
        let dummyUser = User(id: userID, email: "sean@uc.ac.id", fullName: "Sean Tandjaja", profileImageUrl: nil, joinedDate: Date())
        mockAuthRepo.users[userID] = dummyUser
        
        let trip1 = Trip(id: "1", title: "Trip A", locationName: "A", startDate: Date(), endDate: Date(), status: .upcoming, participantIDs: [userID], totalPlaces: 0, createdAt: Date(), createdBy: userID)
        let trip2 = Trip(id: "2", title: "Trip B", locationName: "B", startDate: Date(), endDate: Date(), status: .past, participantIDs: [userID], totalPlaces: 0, createdAt: Date(), createdBy: userID)
        mockFirestoreRepo.trips[userID] = [trip1, trip2]
        
        let viewModel = ProfileViewModel(authRepo: mockAuthRepo, authService: mockAuthService, firestoreRepo: mockFirestoreRepo)
        
        // Act
        viewModel.loadProfile()
        try? await Task.sleep(nanoseconds: 100_000_000) // Beri waktu task async
        
        // Assert
        XCTAssertEqual(viewModel.currentUser?.fullName, "Sean Tandjaja")
        XCTAssertEqual(viewModel.totalTripsCount, 2)
        XCTAssertEqual(viewModel.upcomingTripsCount, 1) // Hanya trip1 yang upcoming/ongoing
    }
    
    @MainActor
    func testRegister_Success_SavesUserToDatabase() async {
        // Arrange
        let viewModel = ProfileViewModel(authRepo: mockAuthRepo, authService: mockAuthService, firestoreRepo: mockFirestoreRepo)
        viewModel.authEmail = "newuser@uc.ac.id"
        viewModel.authPassword = "password123"
        viewModel.authFullName = "Sean Lawton"
        mockAuthService.stubbedUserID = "generated_uid"
        
        // Act
        let success = await viewModel.register()
        
        // Assert
        XCTAssertTrue(success)
        XCTAssertTrue(mockAuthService.didCallRegister)
        XCTAssertNotNil(mockAuthRepo.users["generated_uid"])
        XCTAssertEqual(mockAuthRepo.users["generated_uid"]?.fullName, "Sean Lawton")
    }
    
    @MainActor
    func testLogout_ResetsStateAndStats() {
        // Arrange
        let viewModel = ProfileViewModel(authRepo: mockAuthRepo, authService: mockAuthService, firestoreRepo: mockFirestoreRepo)
        viewModel.currentUser = User(id: "1", email: "a@a.com", fullName: "Name", profileImageUrl: nil, joinedDate: Date())
        viewModel.totalTripsCount = 5
        
        // Act
        viewModel.logout()
        
        // Assert
        XCTAssertTrue(mockAuthService.didCallLogout)
        XCTAssertNil(viewModel.currentUser)
        XCTAssertEqual(viewModel.totalTripsCount, 0)
        XCTAssertEqual(viewModel.upcomingTripsCount, 0)
    }
}
