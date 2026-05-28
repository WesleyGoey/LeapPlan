//
//  AppUser.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String? // Terhubung dengan Firebase Auth UID
    var email: String
    var fullName: String
    var profileImageUrl: String?
    var joinedDate: Date
    
    // Statistik perjalanan telah dihapus untuk mendukung UI Profile yang minimalis
}
