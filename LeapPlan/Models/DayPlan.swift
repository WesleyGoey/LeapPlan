//
//  DayPlan.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import Foundation
import FirebaseFirestore

struct DayPlan: Identifiable, Codable {
    @DocumentID var id: String?
    var dayNumber: Int // Untuk label "Day 1", "Day 2"
    var date: Date     // Tanggal spesifik di kalender untuk hari tersebut
    
    // Array destinasi yang akan dirender sebagai Timeline Nodes.
    // Jika user menekan "Create Manual", array ini awalnya kosong.
    // Jika user menekan "Create Random", array ini otomatis terisi dari AI/Logic.
    var destinations: [TripDestination]
}
