//
//  AuthRepositoryProtocol.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Foundation
import MapKit

protocol AuthRepositoryProtocol {
    func saveUser(_ user: User) async throws
    func fetchUser(userID: String) async throws -> User
    func updateUser(_ user: User) async throws
    func deleteUser(userID: String) async throws
}
