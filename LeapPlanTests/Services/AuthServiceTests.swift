//
//  AuthServiceTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import XCTest
@testable import LeapPlan

final class AuthServiceTests: XCTestCase {
    var authService: AuthService!
    
    override func setUp() {
        super.setUp()
        authService = AuthService()
    }
    
    func testGetCurrentUserID_WhenNotLoggedIn_ReturnsNil() {
        // Kita tes skenario saat user belum login
        let userID = authService.getCurrentUserID()
        XCTAssertNil(userID, "User ID harusnya nil jika belum ada sesi login aktif")
    }
}