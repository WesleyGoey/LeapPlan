//
//  SearchViewModel.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import MapKit
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [FSQPlace] = []
    @Published var selectedPlace: FSQPlace?
    @Published var isLoading: Bool = false
    
    // Default region peta (Bisa diupdate nanti dari LocationService)
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7688), // Koordinat Surabaya
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private let fourSquareService: FourSquareServiceProtocol
    private let locationService: LocationServiceProtocol
    
    init(fourSquareService: FourSquareServiceProtocol = FourSquareService(),
         locationService: LocationServiceProtocol = LocationService()) {
        self.fourSquareService = fourSquareService
        self.locationService = locationService
    }
    
    func performSearch() {
        guard !searchQuery.isEmpty else { return }
        isLoading = true
        
        let center = mapRegion.center
        
        Task {
            do {
                let results = try await fourSquareService.searchPlaces(
                    query: searchQuery,
                    latitude: center.latitude,
                    longitude: center.longitude
                )
                self.searchResults = results
                self.isLoading = false
            } catch {
                print("Error searching places: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
    
    func selectPlace(_ place: FSQPlace) {
        self.selectedPlace = place
        // Opsional: Pindahkan kamera peta ke tempat yang dipilih
    }
}