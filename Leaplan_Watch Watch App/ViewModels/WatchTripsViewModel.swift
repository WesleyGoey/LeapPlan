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
    
    private let tripService: WatchTripServiceProtocol
    
    init(tripService: WatchTripServiceProtocol = WatchTripService()) {
        self.tripService = tripService
    }
    
    // MARK: - Fetch Trips
    func fetchTrips() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                self.trips = try await tripService.getTrips()
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
