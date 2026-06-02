//
//  HomeViewModel.swift
//  LeapPlan
//
//  Created by student on 28/05/26.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var trendingPlaces: [FSQPlace] = []
    @Published var recentTrip: Trip? = nil // Menampung trip dari Firebase
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let fourSquareService: FourSquareServiceProtocol
    private let tripRepository: TripRepositoryProtocol
    
    // Inject repository (Pastikan TripRepository() sudah kamu buat sesuai class aslinya)
    init(fourSquareService: FourSquareServiceProtocol? = nil,
         tripRepository: TripRepositoryProtocol? = nil) {
        self.fourSquareService = fourSquareService ?? FourSquareService()
        self.tripRepository = tripRepository ?? TripRepository()
    }
    
    // Fungsi digabung untuk meload Foursquare dan Firebase sekaligus
    func loadDashboardData(userID: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. Tarik Data Destinasi (API)
                let places = try await fourSquareService.fetchTrendingPlaces(city: "Surabaya")
                self.trendingPlaces = places
                
                // 2. Tarik Data Trip (Firebase)
                let allTrips = try await tripRepository.fetchTrips(forUserID: userID)
                
                // Filter hanya yang upcoming/ongoing, lalu urutkan yang paling dekat
                let activeTrips = allTrips.filter { $0.status == .upcoming || $0.status == .ongoing }
                self.recentTrip = activeTrips.sorted(by: { $0.startDate < $1.startDate }).first
                
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
