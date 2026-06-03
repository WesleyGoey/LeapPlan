//
//  UserRepositoryTests.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class UserRepositoryTests: XCTestCase {
    var sut: AuthRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = AuthRepository()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_repository_shouldInitializeCorrectly() {
        XCTAssertNotNil(sut)
    }
}