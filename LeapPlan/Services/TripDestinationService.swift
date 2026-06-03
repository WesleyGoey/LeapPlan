//
//  TripDestinationService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation

class TripDestinationService: TripDestinationServiceProtocol {
    private let firestoreRepo: FirestoreRepositoryProtocol
    
    init(firestoreRepo: FirestoreRepositoryProtocol = FirestoreRepository()) {
        self.firestoreRepo = firestoreRepo
    }
    
    // Fitur ADD (Tambah Destinasi)
    func addPlaceToTrip(place: FSQPlace, targetTrip: Trip, selectedDays: Set<Int>, userID: String) async throws {
        guard let tripID = targetTrip.id else { return }
        let existingPlans = try await firestoreRepo.fetchDayPlans(forTripID: tripID, userID: userID)
        
        for dayNum in selectedDays {
            if let targetPlanIndex = existingPlans.firstIndex(where: { $0.dayNumber == dayNum }) {
                var updatedPlan = existingPlans[targetPlanIndex]
                let nextIndex = updatedPlan.destinations.count
                
                let newDestination = TripDestination(
                    id: UUID().uuidString,
                    name: place.name,
                    category: "Objek Wisata",
                    foursquareID: place.fsq_place_id,
                    latitude: place.latitude ?? 0.0,
                    longitude: place.longitude ?? 0.0,
                    orderIndex: nextIndex,
                    stayDurationMinutes: 120,
                    transitTimeToNextMinutes: 15,
                    imageURL: place.imageURL
                )
                
                updatedPlan.destinations.append(newDestination)
                try await firestoreRepo.saveDayPlan(updatedPlan, forTripID: tripID, userID: userID)
            }
        }
    }
    
    // MARK: - FITUR REMOVE (Hapus Destinasi untuk Real-time Toggle)
    func removePlaceFromTrip(placeID: String, tripID: String, dayNum: Int, userID: String) async throws {
        let existingPlans = try await firestoreRepo.fetchDayPlans(forTripID: tripID, userID: userID)
        
        // Cari DayPlan yang sesuai dengan hari yang di-uncheck
        if let index = existingPlans.firstIndex(where: { $0.dayNumber == dayNum }) {
            var updatedPlan = existingPlans[index]
            
            // Hapus destinasi yang Foursquare ID-nya cocok
            updatedPlan.destinations.removeAll { $0.foursquareID == placeID }
            
            // Simpan kembali ke Firebase
            try await firestoreRepo.saveDayPlan(updatedPlan, forTripID: tripID, userID: userID)
        }
    }
    
    func saveReorderedDestinations(dayPlan: DayPlan, tripID: String, userID: String) async throws {
        var updatedPlan = dayPlan
        for (index, _) in updatedPlan.destinations.enumerated() {
            updatedPlan.destinations[index].orderIndex = index
        }
        try await firestoreRepo.saveDayPlan(updatedPlan, forTripID: tripID, userID: userID)
    }
    
    func calculateTimeline(for destination: TripDestination, in dayPlan: DayPlan) -> String {
        guard let index = dayPlan.destinations.firstIndex(where: { $0.id == destination.id }) else { return "" }
        var totalMinutes = 9 * 60
        for i in 0..<index {
            let prevDest = dayPlan.destinations[i]
            totalMinutes += prevDest.stayDurationMinutes
            totalMinutes += prevDest.transitTimeToNextMinutes ?? 0
        }
        let hours = (totalMinutes / 60) % 24
        let minutes = totalMinutes % 60
        let ampm = hours >= 12 ? "PM" : "AM"
        let displayHours = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours)
        return String(format: "%02d:%02d %@", displayHours, minutes, ampm)
    }
}
