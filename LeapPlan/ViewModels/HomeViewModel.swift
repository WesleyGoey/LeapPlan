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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var selectedCategory: String = "All"
    
    private let fourSquareService: FourSquareServiceProtocol
    
    init(fourSquareService: FourSquareServiceProtocol = FourSquareService()) {
        self.fourSquareService = fourSquareService
    }
    
    func loadTrendingPlaces(for city: String = "Surabaya") {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let places = try await fourSquareService.fetchTrendingPlaces(city: city)
                self.trendingPlaces = places
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
