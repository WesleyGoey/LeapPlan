//
//  TripGenerationService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

class TripGenerationService: TripGenerationServiceProtocol {
    private let foursquareService: FourSquareServiceProtocol

    // Gunakan Dependency Injection agar bisa di-mock saat testing
    init(foursquareService: FourSquareServiceProtocol = MockFourSquareService())
    {
        self.foursquareService = foursquareService
    }

    func generateRandomItinerary(preferences: RandomTripPreferences)
        async throws -> [DayPlan]
    {
        var dayPlans: [DayPlan] = []
        let calendar = Calendar.current

        // 1. Tarik Data NYATA dari Foursquare berdasarkan Kota
        // 13000 = Dining and Drinking, 16000 = Landmarks and Outdoors
        var availableMeals = try await foursquareService.fetchPlaces(
            near: preferences.locationName,
            categoryID: "13000",
            limit: 30
        )
        var availablePlaces = try await foursquareService.fetchPlaces(
            near: preferences.locationName,
            categoryID: "16000",
            limit: 30
        )

        // 2. Loop berdasarkan jumlah hari yang diatur user
        for (dayIndex, dayPref) in preferences.dailyPreferences.enumerated() {
            guard
                let currentDate = calendar.date(
                    byAdding: .day,
                    value: dayIndex,
                    to: preferences.startDate
                )
            else { continue }

            var destinations: [TripDestination] = []
            var mealsRemaining = dayPref.meals
            var placesRemaining = dayPref.places

            // Susun secara berselang-seling (Makan -> Wisata -> Makan)
            var dailyCategories: [String] = []
            while mealsRemaining > 0 || placesRemaining > 0 {
                if mealsRemaining > 0 {
                    dailyCategories.append("Tempat Makan")
                    mealsRemaining -= 1
                }
                if placesRemaining > 0 {
                    dailyCategories.append("Objek Wisata")
                    placesRemaining -= 1
                }
            }

            // 3. Gabungkan kategori dengan Data Asli Foursquare
            for (orderIndex, category) in dailyCategories.enumerated() {
                let isMeal = (category == "Tempat Makan")

                // Ambil tempat nyata dari array. Jika API habis/kosong, gunakan nama dummy.
                let realPlace =
                    isMeal
                    ? (availableMeals.isEmpty
                        ? nil : availableMeals.removeFirst())
                    : (availablePlaces.isEmpty
                        ? nil : availablePlaces.removeFirst())

                let name =
                    realPlace?.name ?? "Generated \(category) \(orderIndex + 1)"
                let duration = isMeal ? 60 : 120

                let dest = TripDestination(
                    id: UUID().uuidString,
                    name: name,
                    category: category,
                    foursquareID: realPlace?.fsq_place_id,
                    latitude: realPlace?.latitude ?? 0.0,
                    longitude: realPlace?.longitude ?? 0.0,
                    orderIndex: orderIndex,
                    stayDurationMinutes: duration,
                    transitTimeToNextMinutes: 30
                )
                destinations.append(dest)
            }

            let plan = DayPlan(
                id: UUID().uuidString,
                dayNumber: dayPref.dayNumber,
                date: currentDate,
                destinations: destinations
            )
            dayPlans.append(plan)
        }

        return dayPlans
    }
}
