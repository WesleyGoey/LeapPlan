//
//  UserRepositoryProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

protocol UserRepositoryProtocol {
    func fetchUser(userID: String) async throws -> User
    func saveUser(_ user: User) async throws
    func updateUser(_ user: User) async throws
}