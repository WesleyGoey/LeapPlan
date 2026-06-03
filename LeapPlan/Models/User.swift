//
//  User.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var fullName: String
    var profileImageUrl: String?
    var joinedDate: Date
}
