//
//  DayPlan.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct DayPlan: Identifiable, Codable {
    @DocumentID var id: String?
    var dayNumber: Int
    var date: Date

    var destinations: [TripDestination]
}
