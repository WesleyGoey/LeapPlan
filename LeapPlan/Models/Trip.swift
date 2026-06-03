//
//  Trip.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct Trip: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var locationName: String
    var startDate: Date
    var endDate: Date
    var status: TripStatus
    var coverImageUrl: String?

    var participantIDs: [String]
    var totalPlaces: Int = 0

    var createdAt: Date
    var createdBy: String

    var daysUntilTrip: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day],
            from: Date(),
            to: startDate
        )
        return max(0, components.day ?? 0)
    }
}
