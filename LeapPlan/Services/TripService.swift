//
//  TripService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation

class TripService: TripServiceProtocol {
    private let foursquareService: FourSquareServiceProtocol
    private let firestoreRepo: FirestoreRepositoryProtocol

    init(
        foursquareService: FourSquareServiceProtocol = FourSquareService(),
        firestoreRepo: FirestoreRepositoryProtocol = FirestoreRepository()
    ) {
        self.foursquareService = foursquareService
        self.firestoreRepo = firestoreRepo
    }

    // MARK: - Generate Random Itinerary
    func generateRandomItinerary(preferences: RandomTripPreferences)
        async throws -> [DayPlan]
    {
        var dayPlans: [DayPlan] = []
        let calendar = Calendar.current
        let placeCategories = "16000,10027,10055,16032,10044"

        var availablePlaces = try await foursquareService.fetchPlaces(
            near: preferences.locationName,
            categoryID: placeCategories,
            limit: 50
        )

        let invalidWords = [
            "toko", "store", "shop", "mart", "market", "pasar", "supermarket",
            "indomaret", "alfamart", "masjid", "vihara", "gereja", "pura",
            "temple", "shrine", "bank", "atm", "bca", "mandiri", "hotel",
            "penginapan", "kost", "resto", "cafe", "warung", "bakso", "soto",
            "nasi", "mie", "rs", "klinik", "hospital", "xxi", "cgv", "bioskop",
        ]

        availablePlaces.removeAll { place in
            let lowerName = place.name.lowercased()
            return invalidWords.contains(where: { lowerName.contains($0) })
        }

        var addedDict = [String: Bool]()
        availablePlaces = availablePlaces.filter {
            addedDict.updateValue(true, forKey: $0.fsq_place_id) == nil
        }

        availablePlaces.shuffle()
        var usedPlaceIDs = Set<String>()

        for (dayIndex, dayPref) in preferences.dailyPreferences.enumerated() {
            guard
                let currentDate = calendar.date(
                    byAdding: .day,
                    value: dayIndex,
                    to: preferences.startDate
                )
            else { continue }
            var destinations: [TripDestination] = []

            for orderIndex in 0..<dayPref.places {
                if let index = availablePlaces.firstIndex(where: {
                    !usedPlaceIDs.contains($0.fsq_place_id)
                }) {
                    let selectedPlace = availablePlaces.remove(at: index)
                    usedPlaceIDs.insert(selectedPlace.fsq_place_id)

                    let dest = TripDestination(
                        id: UUID().uuidString,
                        name: selectedPlace.name,
                        category: "Objek Wisata",
                        foursquareID: selectedPlace.fsq_place_id,
                        latitude: selectedPlace.latitude ?? 0.0,
                        longitude: selectedPlace.longitude ?? 0.0,
                        orderIndex: orderIndex,
                        stayDurationMinutes: 120,
                        transitTimeToNextMinutes: 30
                    )
                    destinations.append(dest)
                }
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
