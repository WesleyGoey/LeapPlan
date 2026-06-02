//
//  TripsViewModel.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import Combine
import Foundation

@MainActor
class TripsViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let tripRepository: TripRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let tripGenService: TripGenerationServiceProtocol

    init(
        tripRepository: TripRepositoryProtocol = TripRepository(),
        authService: AuthServiceProtocol = AuthService(),
        tripGenService: TripGenerationServiceProtocol = TripGenerationService()
    ) {
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
                self.trips = try await tripRepository.fetchTrips(
                    forUserID: userID
                )
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func createManualTrip(
        title: String,
        location: String,
        start: Date,
        end: Date
    ) {
        guard let userID = authService.getCurrentUserID() else { return }
        let newTrip = Trip(
            title: title,
            locationName: location,
            startDate: start,
            endDate: end,
            status: .upcoming,
            participantIDs: [userID],
            createdAt: Date(),
            createdBy: userID
        )

        Task {
            do {
                try await tripRepository.createTrip(newTrip, forUserID: userID)
                loadUserTrips()  // Refresh list
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func generateRandomTrip(preferences: RandomTripPreferences, title: String) {
        guard let userID = authService.getCurrentUserID() else { return }

        let newTrip = Trip(
            title: title,
            locationName: preferences.locationName,
            startDate: preferences.startDate,
            endDate: preferences.endDate,
            status: .upcoming,
            participantIDs: [userID],
            createdAt: Date(),
            createdBy: userID
        )

        // Pindahkan proses generate ke dalam Task karena sekarang butuh waktu untuk download data dari internet
        Task {
            do {
                // 1. Generate jadwal (sekarang menggunakan try await)
                let generatedDayPlans =
                    try await tripGenService.generateRandomItinerary(
                        preferences: preferences
                    )

                // 2. Simpan Trip dan semua DayPlan sekaligus menggunakan Batch Write!
                try await tripRepository.saveGeneratedTripWithDayPlans(
                    trip: newTrip,
                    dayPlans: generatedDayPlans,
                    userID: userID
                )

                // 3. Muat ulang daftar trip agar trip baru langsung muncul di UI
                loadUserTrips()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
