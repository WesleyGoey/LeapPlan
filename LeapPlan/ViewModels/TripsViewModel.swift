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
    
    func loadUserTrips() {
        guard let userID = authService.getCurrentUserID() else {
            self.errorMessage = "User not logged in"
            return
        }
        
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
        guard let userID = authService.getCurrentUserID() else { return }
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
    
    func generateRandomTrip(preferences: RandomTripPreferences, title: String) {
        guard let userID = authService.getCurrentUserID() else { return }
        
        let newTrip = Trip(title: title, locationName: preferences.locationName, startDate: preferences.startDate, endDate: preferences.endDate, status: .upcoming, participantIDs: [userID], createdAt: Date(), createdBy: userID)
        
        let generatedDayPlans = tripGenService.generateRandomItinerary(preferences: preferences)
        
        Task {
            do {
                try await tripRepository.createTrip(newTrip, forUserID: userID)
                // Setelah trip terbuat, kita asumsikan ID-nya digenerate di Repo, 
                // idealnya fungsi createTrip me-return Trip ID agar bisa di-passing ke DayPlans.
                // Untuk kesederhanaan saat ini, kita butuh penyesuaian di Repo untuk me-return ID.
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
