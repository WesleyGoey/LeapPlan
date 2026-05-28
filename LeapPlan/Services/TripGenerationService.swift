//
//  TripGenerationService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

class TripGenerationService: TripGenerationServiceProtocol {
    
    func generateRandomItinerary(preferences: RandomTripPreferences) -> [DayPlan] {
        var dayPlans: [DayPlan] = []
        let calendar = Calendar.current
        
        for dayIndex in 0..<preferences.totalDays {
            // Hitung tanggal untuk hari ini
            guard let currentDate = calendar.date(byAdding: .day, value: dayIndex, to: preferences.startDate) else { continue }
            
            var destinations: [TripDestination] = []
            
            // Loop untuk membuat Mock Destination (Tempat Makan & Tempat Wisata)
            let totalActivities = preferences.mealsPerDay + preferences.placesToVisitPerDay
            
            for order in 0..<totalActivities {
                // Alternating antara makan dan wisata
                let isMeal = order % 2 == 0 
                let category = isMeal ? "Tempat Makan" : "Objek Wisata"
                let duration = isMeal ? 60 : 120 // 1 jam makan, 2 jam wisata
                
                let mockDest = TripDestination(
                    name: "Generated \(category) \(order + 1)",
                    category: category,
                    foursquareID: nil,
                    latitude: 0.0, // Nanti diisi logic API Foursquare / Coordinates kota tujuan
                    longitude: 0.0,
                    orderIndex: order,
                    stayDurationMinutes: duration,
                    transitTimeToNextMinutes: 30
                )
                destinations.append(mockDest)
            }
            
            let plan = DayPlan(
                dayNumber: dayIndex + 1,
                date: currentDate,
                destinations: destinations
            )
            dayPlans.append(plan)
        }
        
        return dayPlans
    }
}