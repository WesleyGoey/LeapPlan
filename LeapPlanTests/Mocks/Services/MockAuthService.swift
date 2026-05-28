//
//  MockAuthService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
@testable import LeapPlan

class MockAuthService: AuthServiceProtocol {
    var shouldReturnError = false
    var mockUserID: String? = "TEST_USER_123"
    var isLoggedOut = false
    
    func getCurrentUserID() -> String? {
        return mockUserID
    }
    
    func logout() throws {
        if shouldReturnError {
            throw NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Logout Gagal"])
        }
        isLoggedOut = true
        mockUserID = nil
    }
}