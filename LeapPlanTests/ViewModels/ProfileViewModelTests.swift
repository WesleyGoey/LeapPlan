//
//  ProfileViewModelTests.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//


import XCTest
import Combine
@testable import LeapPlan

@MainActor
final class ProfileViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() { super.setUp(); cancellables = [] }

    func testLoadProfile_Success() async {
        let mockRepo = MockUserRepository()
        let mockAuth = MockAuthService()
        mockRepo.mockUser = User(id: "1", email: "test@test.com", fullName: "Sean Tandjaja", joinedDate: Date())
        let viewModel = ProfileViewModel(userRepository: mockRepo, authService: mockAuth)
        
        let expectation = XCTestExpectation(description: "Wait for profile")
        viewModel.$currentUser.dropFirst().sink { if $0 != nil { expectation.fulfill() } }.store(in: &cancellables)

        viewModel.loadProfile()
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(viewModel.currentUser?.fullName, "Sean Tandjaja")
    }
}