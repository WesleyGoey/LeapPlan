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
            guard let currentDate = calendar.date(byAdding: .day, value: dayIndex, to: preferences.startDate) else { continue }
            
            var destinations: [TripDestination] = []
            
            let totalActivities = preferences.mealsPerDay + preferences.placesToVisitPerDay
            
            for order in 0..<totalActivities {
                let isMeal = order % 2 == 0 
                let category = isMeal ? "Tempat Makan" : "Objek Wisata"
                let duration = isMeal ? 60 : 120
                
                let mockDest = TripDestination(
                    name: "Generated \(category) \(order + 1)",
                    category: category,
                    foursquareID: nil,
                    latitude: 0.0,
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
