//
//  HomeViewModel.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import Combine
import FirebaseAuth
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var trendingPlaces: [FSQPlace] = []
    @Published var recentTrip: Trip? = nil
    @Published var recentTripPlacesCount: Int = 0

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let fourSquareService: FourSquareServiceProtocol
    private let firestoreRepo: FirestoreRepositoryProtocol
    private let authService: AuthServiceProtocol

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var hasInitialized = false

    init(
        fourSquareService: FourSquareServiceProtocol? = nil,
        firestoreRepo: FirestoreRepositoryProtocol? = nil,
        authService: AuthServiceProtocol? = nil
    ) {

        self.fourSquareService = fourSquareService ?? FourSquareService()
        self.firestoreRepo = firestoreRepo ?? FirestoreRepository()
        self.authService = authService ?? AuthService()

        setupAuthListener()
    }

    private func setupAuthListener() {
        self.authStateHandle = Auth.auth().addStateDidChangeListener {
            [weak self] _, user in
            Task { @MainActor in
                guard let self = self else { return }
                if user == nil {
                    self.recentTrip = nil
                }
                await self.loadDashboardData()
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func loadDashboardData() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            if trendingPlaces.isEmpty {
                self.trendingPlaces =
                    try await fourSquareService.fetchTrendingPlaces(
                        city: "Surabaya"
                    )
            }

            if let userID = authService.getCurrentUserID() {
                let allTrips = try await firestoreRepo.fetchTrips(
                    forUserID: userID
                )
                let activeTrips = allTrips.filter {
                    $0.status == .upcoming || $0.status == .ongoing
                }
                self.recentTrip =
                    activeTrips.sorted(by: { $0.startDate < $1.startDate })
                    .first

                if let trip = self.recentTrip, let tripID = trip.id {
                    let dayPlans = try await firestoreRepo.fetchDayPlans(
                        forTripID: tripID,
                        userID: userID
                    )
                    self.recentTripPlacesCount = dayPlans.reduce(0) {
                        $0 + $1.destinations.count
                    }
                } else {
                    self.recentTripPlacesCount = 0
                }

            } else {
                self.recentTrip = nil
                self.recentTripPlacesCount = 0
            }

            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
