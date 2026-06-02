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

        // 1. KATEGORI KHUSUS OBJEK WISATA SAJA (HAPUS KATEGORI RESTORAN)
        // 16000 = Landmarks, 10027 = Museum, 10055 = Theme Park, 16032 = Park, 16003 = Beach, 10044 = Historic Site
        let placeCategories = "16000,10027,10055,16032,16003,10044"

        // Kita tarik 50 data agar cadangannya banyak kalau yang aneh-aneh dibuang
        var availablePlaces = try await foursquareService.fetchPlaces(near: preferences.locationName, categoryID: placeCategories, limit: 50)

        // ==========================================================
        // 2. FILTERING KATA "ULTRA-STRICT" (Anti Data Ngaco)
        // ==========================================================
        
        // Daftar kata yang HARAM muncul sebagai Objek Wisata (Termasuk Kampus & Tempat Ibadah)
        let invalidPlaceWords = [
            // Tempat Ibadah & Agama
            "vihara", "masjid", "gereja", "pura", "temple", "shrine", "mosque", "church", "wihara",
            // Pendidikan
            "sekolah", "kampus", "universitas", "school", "university", "college", "institut", "akademi",
            // Perbelanjaan harian
            "toko", "store", "shop", "gift", "mart", "market", "pasar", "supermarket", "indomaret", "alfamart", "apotek",
            // Keuangan
            "bank", "atm", "bca", "mandiri", "bni", "bri", "cimb",
            // Penginapan
            "hotel", "resort", "villa", "guest house", "penginapan", "kost",
            // Makanan
            "warung", "resto", "restaurant", "cafe", "kopi", "coffee", "depot", "rumah makan", "kedai", "canteen", "kantin",
            "bakso", "soto", "sate", "nasi", "mie", "ayam", "bebek", "ikan", "seafood", "bakar", "goreng", "martabak", "kue", "bakery", "burger", "pizza",
            // Kesehatan & Bioskop
            "rs", "klinik", "hospital", "puskesmas", "xxi", "cgv", "cinema", "bioskop"
        ]
        
        // Eksekusi filter pembersihan (Sapu bersih tempat aneh!)
        availablePlaces.removeAll { place in
            let lowerName = place.name.lowercased()
            return invalidPlaceWords.contains(where: { lowerName.contains($0) })
        }

        // ==========================================================
        // 3. PROSES NORMAL (Hapus Duplikat & Acak)
        // ==========================================================
        availablePlaces = availablePlaces.removingDuplicates()
        availablePlaces.shuffle()

        var usedPlaceIDs = Set<String>()

        // 4. Loop per Hari
        for (dayIndex, dayPref) in preferences.dailyPreferences.enumerated() {
            guard let currentDate = calendar.date(byAdding: .day, value: dayIndex, to: preferences.startDate) else { continue }

            var destinations: [TripDestination] = []
            
            // HANYA MENGAMBIL JUMLAH "PLACES" DARI PREFERENSI (Abaikan Meals)
            let placesToVisit = dayPref.places

            for orderIndex in 0..<placesToVisit {
                var selectedPlace: FSQPlace? = nil

                // Cari tempat dari array yang BELUM PERNAH digunakan di trip ini
                if let index = availablePlaces.firstIndex(where: { !usedPlaceIDs.contains($0.fsq_place_id) }) {
                    selectedPlace = availablePlaces.remove(at: index)
                }

                // Catat ID tempat ini agar tidak dipakai lagi di hari selanjutnya
                if let placeID = selectedPlace?.fsq_place_id {
                    usedPlaceIDs.insert(placeID)
                }

                // Fallback cerdas jika kebetulan semua data dari Foursquare terlalu ngaco dan habis
                let name = selectedPlace?.name ?? "Famous Landmark \(orderIndex + 1)"
                let duration = 120 // Default durasi wisata 2 jam

                let dest = TripDestination(
                    id: UUID().uuidString,
                    name: name,
                    category: "Objek Wisata",
                    foursquareID: selectedPlace?.fsq_place_id,
                    latitude: selectedPlace?.latitude ?? 0.0,
                    longitude: selectedPlace?.longitude ?? 0.0,
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

// MARK: - Helper Extension
extension Array where Element == FSQPlace {
    func removingDuplicates() -> [FSQPlace] {
        var addedDict = [String: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0.fsq_place_id) == nil
        }
    }
}
