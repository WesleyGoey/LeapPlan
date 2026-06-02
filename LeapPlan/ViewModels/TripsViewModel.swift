//
//  TripsViewModel.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import Foundation
import Combine

@MainActor
class TripsViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let tripRepository: TripRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let tripGenService: TripGenerationServiceProtocol
    
    init(tripRepository: TripRepositoryProtocol = TripRepository(),
         authService: AuthServiceProtocol = AuthService(),
         tripGenService: TripGenerationServiceProtocol = TripGenerationService()) {
        self.tripRepository = tripRepository
        self.authService = authService
        self.tripGenService = tripGenService
    }
    
    // MARK: - HELPER UNTUK MENDAPATKAN USER
    // Jika belum login, gunakan "dummy_user_123" agar testing tetap bisa berjalan
    private var activeUserID: String {
        return authService.getCurrentUserID() ?? "dummy_user_123"
    }
    
    func loadUserTrips() {
        let userID = activeUserID
        isLoading = true
        
        Task {
            do {
                self.trips = try await tripRepository.fetchTrips(forUserID: userID)
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func createManualTrip(title: String, location: String, start: Date, end: Date) {
        let userID = activeUserID
        let newTrip = Trip(title: title, locationName: location, startDate: start, endDate: end, status: .upcoming, participantIDs: [userID], createdAt: Date(), createdBy: userID)
        
        Task {
            do {
                try await tripRepository.createTrip(newTrip, forUserID: userID)
                loadUserTrips() // Refresh list
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func generateRandomTrip(preferences: RandomTripPreferences, title: String) async throws -> Trip {
        let userID = activeUserID
        
        var newTrip = Trip(title: title, locationName: preferences.locationName, startDate: preferences.startDate, endDate: preferences.endDate, status: .upcoming, participantIDs: [userID], createdAt: Date(), createdBy: userID)
        newTrip.coverImageUrl = "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=800&auto=format&fit=crop"
        
        // 1. Generate Jadwal dari Foursquare
        let generatedDayPlans = try await tripGenService.generateRandomItinerary(preferences: preferences)
        
        // 2. Simpan ke Firebase dengan ID Pengguna Sementara
        try await tripRepository.saveGeneratedTripWithDayPlans(trip: newTrip, dayPlans: generatedDayPlans, userID: userID)
        
        // 3. Refresh Halaman Utama
        await MainActor.run { self.loadUserTrips() }
        
        return newTrip
    }
}
