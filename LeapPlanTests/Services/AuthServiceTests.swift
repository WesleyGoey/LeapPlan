//
//  AuthServiceTests.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//


import XCTest
@testable import LeapPlan

final class AuthServiceTests: XCTestCase {
    // SUT
    var sut: AuthService! // Gunakan instance aslinya
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // PENTING: Untuk service asli, kamu bisa menggunakan mock URLSession jika tidak memakai Firebase SDK langsung
        sut = AuthService() 
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_initialAuthState_shouldBeDetermined() {
        // Ini contoh mengecek apakah service bisa mendeteksi state awal dengan benar
        XCTAssertNotNil(sut)
    }
}