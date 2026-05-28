
//
//  TripStatus.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import Foundation
import FirebaseFirestore

enum TripStatus: String, Codable {
    case upcoming = "Upcoming"
    case ongoing = "Ongoing"
    case completed = "Completed"
}

struct Trip: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String          // Contoh: "Bali Escapade" atau "Kyoto Autumn"
    var locationName: String   // Lokasi utama trip
    var startDate: Date
    var endDate: Date
    var status: TripStatus
    var coverImageUrl: String? // Digunakan untuk background image di Widget & Trip Card
    
    // Kolaborasi Real-time
    var participantIDs: [String]
    
    // Metadata
    var createdAt: Date
    var createdBy: String
    
    // Computed property: Sangat berguna untuk UI "Countdown: X Days Left" di Home Tab
    var daysUntilTrip: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: startDate)
        return max(0, components.day ?? 0)
    }
}
