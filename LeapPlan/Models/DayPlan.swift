//
//  DayPlan.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
import Foundation

struct DayPlan: Identifiable, Codable {
#if canImport(FirebaseFirestore)
    @DocumentID var id: String?
#else
    var id: String?
#endif
    var dayNumber: Int
    var date: Date

    var destinations: [TripDestination]
}
