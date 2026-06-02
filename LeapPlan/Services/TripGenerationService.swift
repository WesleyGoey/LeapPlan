//
//  TripGenerationService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

class TripGenerationService: TripGenerationServiceProtocol {
    private let foursquareService: FourSquareServiceProtocol

    init(foursquareService: FourSquareServiceProtocol = FourSquareService()) {
        self.foursquareService = foursquareService
    }

    func generateRandomItinerary(preferences: RandomTripPreferences) async throws -> [DayPlan] {
        var dayPlans: [DayPlan] = []
        let calendar = Calendar.current

        // HANYA kategori wisata (16000=Landmarks, 10027=Museum, 10055=Theme Park, 16032=Park, 10044=Historic)
        let placeCategories = "16000,10027,10055,16032,10044"

        // Tarik 50 data agar filter bisa bekerja maksimal
        var availablePlaces = try await foursquareService.fetchPlaces(near: preferences.locationName, categoryID: placeCategories, limit: 50)

        // FILTER KATA "HARAM" (Biar gak muncul Toko, Masjid, dll)
        let invalidWords = [
            "toko", "store", "shop", "mart", "market", "pasar", "supermarket", "indomaret", "alfamart", // Perbelanjaan
            "masjid", "vihara", "gereja", "pura", "temple", "shrine", // Ibadah
            "bank", "atm", "bca", "mandiri", // Keuangan
            "hotel", "penginapan", "kost", // Penginapan
            "resto", "cafe", "warung", "bakso", "soto", "nasi", "mie", // Makanan
            "rs", "klinik", "hospital", "xxi", "cgv", "bioskop" // Kesehatan & Bioskop
        ]
        
        availablePlaces.removeAll { place in
            let lowerName = place.name.lowercased()
            return invalidWords.contains(where: { lowerName.contains($0) })
        }

        availablePlaces = availablePlaces.removingDuplicates()
        availablePlaces.shuffle()

        var usedPlaceIDs = Set<String>()

        for (dayIndex, dayPref) in preferences.dailyPreferences.enumerated() {
            guard let currentDate = calendar.date(byAdding: .day, value: dayIndex, to: preferences.startDate) else { continue }
            var destinations: [TripDestination] = []

            for orderIndex in 0..<dayPref.places {
                if let index = availablePlaces.firstIndex(where: { !usedPlaceIDs.contains($0.fsq_place_id) }) {
                    let selectedPlace = availablePlaces.remove(at: index)
                    usedPlaceIDs.insert(selectedPlace.fsq_place_id)

                    let dest = TripDestination(
                        id: UUID().uuidString,
                        name: selectedPlace.name,
                        category: "Objek Wisata",
                        foursquareID: selectedPlace.fsq_place_id,
                        latitude: selectedPlace.latitude!,
                        longitude: selectedPlace.longitude!,
                        orderIndex: orderIndex,
                        stayDurationMinutes: 120,
                        transitTimeToNextMinutes: 30
                    )
                    destinations.append(dest)
                }
            }

            let plan = DayPlan(id: UUID().uuidString, dayNumber: dayPref.dayNumber, date: currentDate, destinations: destinations)
            dayPlans.append(plan)
        }
        return dayPlans
    }
}

// MARK: - Helper Extension
extension Array where Element == FSQPlace {
    func removingDuplicates() -> [FSQPlace] {
        var addedDict = [String: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0.fsq_place_id) == nil
        }
    }
}
