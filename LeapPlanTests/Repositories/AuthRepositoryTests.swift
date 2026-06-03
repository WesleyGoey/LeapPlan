//
//  AuthRepositoryTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//



import XCTest
import FirebaseFirestore
@testable import LeapPlan

final class AuthRepositoryTests: XCTestCase {
    
    var repository: AuthRepository!
    let testUserID = "test_user_sean_123"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        repository = AuthRepository()
        
        // REVISI: Mengarahkan koneksi ke Local Firebase Emulator Suite (Port 8080)
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
    }
    
    override func tearDownWithError() throws {
        repository = nil
        try super.tearDownWithError()
    }
    
    func testSaveAndFetchUser_Success() async throws {
        // Arrange
        let dummyUser = User(id: testUserID, email: "sean@uc.ac.id", fullName: "Sean Tandjaja Tandjaja", profileImageUrl: nil, joinedDate: Date())
        
        // Act: Simpan User
        try await repository.saveUser(dummyUser)
        
        // Act: Ambil Kembali
        let fetchedUser = try await repository.fetchUser(userID: testUserID)
        
        // Assert
        XCTAssertEqual(fetchedUser.id, dummyUser.id)
        XCTAssertEqual(fetchedUser.fullName, "Sean Tandjaja Tandjaja")
        XCTAssertEqual(fetchedUser.email, "sean@uc.ac.id")
    }
    
    func testUpdateAndDeleteUser_Success() async throws {
        // Arrange
        var dummyUser = User(id: testUserID, email: "sean@uc.ac.id", fullName: "Sean Tandjaja", profileImageUrl: nil, joinedDate: Date())
        try await repository.saveUser(dummyUser)
        
        // Act: Update Nama Lengkap
        dummyUser.fullName = "Sean Lawton Tandjaja"
        try await repository.updateUser(dummyUser)
        
        let updatedUser = try await repository.fetchUser(userID: testUserID)
        XCTAssertEqual(updatedUser.fullName, "Sean Lawton Tandjaja")
        
        // Act: Hapus User
        try await repository.deleteUser(userID: testUserID)
        
        // Assert: Pastikan Data Hilang (Throws Error 404)
        do {
            _ = try await repository.fetchUser(userID: testUserID)
            XCTFail("Harusnya melempar error karena data sudah dihapus.")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 404)
        }
    }
}
