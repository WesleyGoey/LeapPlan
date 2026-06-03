//
//  AuthServiceTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import XCTest
import FirebaseAuth
@testable import LeapPlan

final class AuthServiceTests: XCTestCase {
    
    var service: AuthService!
    var mockAuthRepo: MockAuthRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAuthRepo = MockAuthRepository()
        service = AuthService(authRepo: mockAuthRepo)
        
        // Sambungkan ke Firebase Auth Local Emulator
        Auth.auth().useEmulator(withHost: "localhost", port: 9099)
    }
    
    override func tearDownWithError() throws {
        service = nil
        mockAuthRepo = nil
        try super.tearDownWithError()
    }
    
    func testLogout_ClearsSessionState() throws {
        // Act: Panggil sign out
        // Jika emulator kosong, fungsi ini tetap aman membersihkan status lokal SDK
        try? service.logout()
        
        // Assert
        XCTAssertFalse(service.isLoggedIn)
        XCTAssertNil(service.getCurrentUserID())
    }
}
