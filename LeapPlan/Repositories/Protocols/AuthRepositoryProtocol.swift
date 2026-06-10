//
//  AuthRepositoryProtocol.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Foundation
import MapKit

protocol AuthRepositoryProtocol {
    // MARK: - Save User
    func saveUser(_ user: User) async throws
    // MARK: - Fetch User
    func fetchUser(userID: String) async throws -> User
    // MARK: - Update User
    func updateUser(_ user: User) async throws
    // MARK: - Delete User
    func deleteUser(userID: String) async throws
}
