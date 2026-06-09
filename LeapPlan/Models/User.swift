//
//  User.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
import Foundation

struct User: Identifiable, Codable {
#if canImport(FirebaseFirestore)
    @DocumentID var id: String?
#else
    var id: String?
#endif
    var email: String
    var fullName: String
    var profileImageUrl: String?
    var joinedDate: Date
}
