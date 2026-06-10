//
//  WatchTripsViewModel.swift
//  Leaplan_Watch Watch App
//
//  Created by Wesley Goey on 10/06/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class WatchTripsViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let sessionManager: WatchSessionManager
    private let tripService: WatchTripServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        sessionManager: WatchSessionManager = WatchSessionManager.shared,
        tripService: WatchTripServiceProtocol = WatchTripService()
    ) {
        self.sessionManager = sessionManager
        self.tripService = tripService

        // Automatically react to trips pushed via WatchConnectivity (Application Context)
        sessionManager.$syncedTrips
            .receive(on: RunLoop.main)
            .sink { [weak self] newTrips in
                guard let self = self else { return }
                let filtered = newTrips
                    .filter { $0.status == .ongoing || $0.status == .upcoming }
                    .sorted { trip1, trip2 in
                        let order1 = trip1.status == .ongoing ? 0 : 1
                        let order2 = trip2.status == .ongoing ? 0 : 1
                        if order1 != order2 { return order1 < order2 }
                        return trip1.startDate < trip2.startDate
                    }
                // Only update if we have real data (don't wipe live-fetched data with empty)
                if !filtered.isEmpty || !self.trips.isEmpty {
                    self.trips = filtered
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch Trips
    func fetchTrips() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetched = try await tripService.getTrips()
                let filtered = fetched
                    .filter { $0.status == .ongoing || $0.status == .upcoming }
                    .sorted { trip1, trip2 in
                        let order1 = trip1.status == .ongoing ? 0 : 1
                        let order2 = trip2.status == .ongoing ? 0 : 1
                        if order1 != order2 { return order1 < order2 }
                        return trip1.startDate < trip2.startDate
                    }
                self.trips = filtered
                self.isLoading = false
            } catch {
                // If live fetch fails, fall back to whatever WatchSessionManager already has
                if !self.sessionManager.syncedTrips.isEmpty {
                    let cached = self.sessionManager.syncedTrips
                        .filter { $0.status == .ongoing || $0.status == .upcoming }
                        .sorted { t1, t2 in
                            let o1 = t1.status == .ongoing ? 0 : 1
                            let o2 = t2.status == .ongoing ? 0 : 1
                            if o1 != o2 { return o1 < o2 }
                            return t1.startDate < t2.startDate
                        }
                    self.trips = cached
                    self.isLoading = false
                } else {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
