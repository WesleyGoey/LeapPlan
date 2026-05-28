//
//  TripDetailViewModel.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import MapKit
import Combine

@MainActor
class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var dayPlans: [DayPlan] = []
    @Published var selectedDayIndex: Int = 0 {
        didSet {
            calculateRouteForSelectedDay()
        }
    }
    
    @Published var mapRoute: MKPolyline?
    @Published var isLoading: Bool = false
    
    private let tripRepository: TripRepositoryProtocol
    private let authService: AuthServiceProtocol
    
    init(trip: Trip, tripRepository: TripRepositoryProtocol = TripRepository(), authService: AuthServiceProtocol = AuthService()) {
        self.trip = trip
        self.tripRepository = tripRepository
        self.authService = authService
    }
    
    func loadDayPlans() {
        guard let tripID = trip.id, let userID = authService.getCurrentUserID() else { return }
        isLoading = true
        
        Task {
            do {
                self.dayPlans = try await tripRepository.fetchDayPlans(forTripID: tripID, userID: userID)
                calculateRouteForSelectedDay()
                self.isLoading = false
            } catch {
                print("Error loading day plans: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
    
    func calculateRouteForSelectedDay() {
        guard dayPlans.indices.contains(selectedDayIndex) else {
            self.mapRoute = nil
            return
        }
        
        let destinations = dayPlans[selectedDayIndex].destinations
        guard destinations.count > 1 else {
            self.mapRoute = nil
            return
        }
        
        var coordinates = destinations.map { $0.coordinate }
        self.mapRoute = MKPolyline(coordinates: &coordinates, count: coordinates.count)
    }
}
