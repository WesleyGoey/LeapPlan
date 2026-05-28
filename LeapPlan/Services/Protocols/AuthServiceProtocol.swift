//
//  AuthServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

protocol AuthServiceProtocol {
    func getCurrentUserID() -> String?
    func logout() throws
}
