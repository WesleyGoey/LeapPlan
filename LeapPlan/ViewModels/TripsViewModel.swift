//
//  TripsViewModel.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import Foundation
import Combine
import UIKit

@MainActor
class TripsViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let tripRepository: TripRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let tripGenService: TripGenerationServiceProtocol
    
    init(tripRepository: TripRepositoryProtocol? = nil,
         authService: AuthServiceProtocol? = nil,
         tripGenService: TripGenerationServiceProtocol? = nil) {
        self.tripRepository = tripRepository ?? TripRepository()
        self.authService = authService ?? AuthService()
        self.tripGenService = tripGenService ?? TripGenerationService()
    }
    
    private var activeUserID: String {
        return authService.getCurrentUserID() ?? "dummy_user_123"
    }
    
    func loadUserTrips() {
        let userID = activeUserID
        isLoading = true
        Task {
            do { self.trips = try await tripRepository.fetchTrips(forUserID: userID); self.isLoading = false }
            catch { self.errorMessage = error.localizedDescription; self.isLoading = false }
        }
    }
    
    // MARK: - BARU: FITUR TAMBAH TEMPAT DARI SEARCH TAB KE ITINERARY BATCH & MULTI-DAY
    func addPlaceToTrip(place: FSQPlace, targetTrip: Trip, selectedDays: Set<Int>) async {
        guard let tripID = targetTrip.id else { return }
        let userID = activeUserID
        isLoading = true
        
        do {
            // 1. Tarik semua DayPlan yang ada di Trip tersebut dari Firebase
            let existingPlans = try await tripRepository.fetchDayPlans(forTripID: tripID, userID: userID)
            
            // 2. Loop untuk menyisipkan ke setiap hari yang di-checklist oleh user
            for dayNum in selectedDays {
                if let targetPlanIndex = existingPlans.firstIndex(where: { $0.dayNumber == dayNum }) {
                    var updatedPlan = existingPlans[targetPlanIndex]
                    
                    // Hitung urutan indeks paling bawah
                    let nextIndex = updatedPlan.destinations.count
                    
                    // Ubah data Foursquare menjadi format TripDestination aplikasi kita
                    let newDestination = TripDestination(
                        id: UUID().uuidString,
                        name: place.name,
                        category: "Objek Wisata",
                        foursquareID: place.fsq_place_id,
                        latitude: place.latitude ?? -7.2504,
                        longitude: place.longitude ?? 112.7688,
                        orderIndex: nextIndex,
                        stayDurationMinutes: 120, // Default 2 Jam kunjung
                        transitTimeToNextMinutes: 15
                    )
                    
                    updatedPlan.destinations.append(newDestination)
                    
                    // 3. Simpan perubahan kembali ke Firebase
                    try await tripRepository.saveDayPlan(updatedPlan, forTripID: tripID, userID: userID)
                }
            }
            loadUserTrips() // Refresh UI data lokal
        } catch {
            print("Gagal menambahkan destinasi: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func createManualTrip(title: String, location: String, start: Date, end: Date) {
        let userID = activeUserID
        let newTrip = Trip(title: title, locationName: location, startDate: start, endDate: end, status: .upcoming, participantIDs: [userID], createdAt: Date(), createdBy: userID)
        Task { do { try await tripRepository.createTrip(newTrip, forUserID: userID); loadUserTrips() } catch { self.errorMessage = error.localizedDescription } }
    }
    
    func generateRandomTrip(preferences: RandomTripPreferences, title: String) async throws -> Trip {
        let userID = activeUserID
        var newTrip = Trip(title: title, locationName: preferences.locationName, startDate: preferences.startDate, endDate: preferences.endDate, status: .upcoming, participantIDs: [userID], createdAt: Date(), createdBy: userID)
        newTrip.coverImageUrl = "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=800&auto=format&fit=crop"
        
        let generatedDayPlans = try await tripGenService.generateRandomItinerary(preferences: preferences)
        try await tripRepository.saveGeneratedTripWithDayPlans(trip: newTrip, dayPlans: generatedDayPlans, userID: userID)
        
        await MainActor.run { self.loadUserTrips() }
        return newTrip
    }
    
    func deleteTrip(tripID: String) {
        let userID = activeUserID
        isLoading = true
        Task {
            do {
                try await tripRepository.deleteTrip(tripID: tripID, forUserID: userID)
                await MainActor.run { self.loadUserTrips() }
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func updateTripDetails(trip: Trip, title: String, startDate: Date, endDate: Date, coverImageUrl: String) async {
        isLoading = true
        var updatedTrip = trip
        updatedTrip.title = title
        updatedTrip.startDate = startDate
        updatedTrip.endDate = endDate
        if !coverImageUrl.isEmpty { updatedTrip.coverImageUrl = coverImageUrl }
        
        let userID = activeUserID
        guard let tripID = updatedTrip.id else { return }
        
        do {
            try await tripRepository.updateTrip(updatedTrip, forUserID: userID)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: calendar.startOfDay(for: endDate))
            let totalDays = max(1, (components.day ?? 0) + 1)
            let existingDayPlans = try await tripRepository.fetchDayPlans(forTripID: tripID, userID: userID)
            
            if existingDayPlans.count > totalDays {
                let plansToDelete = Array(existingDayPlans[totalDays...])
                for plan in plansToDelete {
                    if let planID = plan.id {
                        try await tripRepository.deleteDayPlan(planID: planID, tripID: tripID, userID: userID)
                    }
                }
            } else if existingDayPlans.count < totalDays {
                for i in (existingDayPlans.count + 1)...totalDays {
                    guard let newDate = calendar.date(byAdding: .day, value: i - 1, to: calendar.startOfDay(for: startDate)) else { continue }
                    let newPlan = DayPlan(id: UUID().uuidString, dayNumber: i, date: newDate, destinations: [])
                    try await tripRepository.saveDayPlan(newPlan, forTripID: tripID, userID: userID)
                }
            }
            await MainActor.run { self.loadUserTrips() }
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    func saveImageLocally(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.6) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url.absoluteString
        } catch {
            return nil
        }
    }
}
