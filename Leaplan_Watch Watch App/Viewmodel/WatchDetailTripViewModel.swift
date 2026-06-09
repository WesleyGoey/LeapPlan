//
//  WatchDetailTripViewModel.swift
//  Leaplan_Watch Watch App
//

import Combine
import Foundation
import MapKit
import SwiftUI

@MainActor
final class WatchDetailTripViewModel: ObservableObject {
    @Published var dayPlans: [DayPlan] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let tripService: WatchTripServiceProtocol
    let trip: Trip
    
    init(trip: Trip, tripService: WatchTripServiceProtocol = WatchTripService()) {
        self.trip = trip
        self.tripService = tripService
    }
    
    func fetchTripDetails() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let tripId = trip.id else {
                    throw NSError(domain: "WatchDetailTripViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid trip ID"])
                }
                let plans = try await tripService.getTripDetails(tripId: tripId)
                self.dayPlans = plans.sorted(by: { $0.dayNumber < $1.dayNumber })
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    var allDestinations: [TripDestination] {
        return dayPlans.flatMap { $0.destinations }.sorted(by: { $0.orderIndex < $1.orderIndex })
    }
    
    var totalStops: Int {
        return allDestinations.count
    }
    
    var totalDurationHours: Double {
        let totalMinutes = allDestinations.reduce(0) { $0 + $1.stayDurationMinutes + ($1.transitTimeToNextMinutes ?? 0) }
        return Double(totalMinutes) / 60.0
    }
    
    var initialRegion: MKCoordinateRegion {
        let destinations = allDestinations
        guard !destinations.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
        
        let latitudes = destinations.map { $0.latitude }
        let longitudes = destinations.map { $0.longitude }
        
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLon = longitudes.max()!
        let minLon = longitudes.min()!
        
        let centerLat = (maxLat + minLat) / 2
        let centerLon = (maxLon + minLon) / 2
        
        // Add a little padding to the span
        let latDelta = max(0.01, (maxLat - minLat) * 1.5)
        let lonDelta = max(0.01, (maxLon - minLon) * 1.5)
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
}
