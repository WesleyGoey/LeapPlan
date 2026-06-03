//
//  MockAuthService.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import Foundation
@testable import LeapPlan // Ganti jika nama target utamamu berbeda

class MockAuthService: AuthServiceProtocol {
    var isLoggedIn: Bool = true
    var stubbedUserID: String? = "test_user_123"
    
    func getCurrentUserID() -> String? {
        return stubbedUserID
    }
}