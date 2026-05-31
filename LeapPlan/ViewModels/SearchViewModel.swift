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
    @Published var errorMessage: String? = nil // Tambahan variabel penampung error
    
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7688), // Default Surabaya
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private let fourSquareService: FourSquareServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(fourSquareService: FourSquareServiceProtocol = FourSquareService(),
         locationService: LocationServiceProtocol = LocationService()) {
        self.fourSquareService = fourSquareService
        self.locationService = locationService
        
        setupLiveSearch()
    }
    
    private func setupLiveSearch() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                if !query.isEmpty {
                    self.performSearch()
                } else {
                    self.searchResults = []
                    self.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func performSearch() {
        guard !searchQuery.isEmpty else { return }
        isLoading = true
        errorMessage = nil // Reset error setiap mulai mencari
        
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
                // Tampilkan pesan error asli ke UI text
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("Error searching places: \(error.localizedDescription)")
            }
        }
    }
    
    func selectPlace(_ place: FSQPlace) {
        self.selectedPlace = place
        self.searchQuery = place.name
        
        self.mapRegion = MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func centerToCurrentLocation() {
        self.mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7688),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}
