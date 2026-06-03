//
//  SearchViewModel.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import MapKit
import Combine
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [FSQPlace] = []
    @Published var displayedPins: [FSQPlace] = []
    @Published var selectedPlace: FSQPlace?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7688),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    private let fourSquareService: FourSquareServiceProtocol
    private let locationService: LocationServiceProtocol
    private let authService: AuthServiceProtocol // BARU: Untuk cek status login
    private var cancellables = Set<AnyCancellable>()
    
    init(fourSquareService: FourSquareServiceProtocol? = nil,
         locationService: LocationServiceProtocol? = nil,
         authService: AuthServiceProtocol? = nil) {
        self.fourSquareService = fourSquareService ?? FourSquareService()
        self.locationService = locationService ?? LocationService()
        self.authService = authService ?? AuthService()
        
        setupLiveSearch()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.centerToCurrentLocation()
        }
    }
    
    // Properti ini yang akan dipakai View untuk mematikan/menyalakan tombol
    var isLoggedIn: Bool {
        return authService.isLoggedIn
    }
    
    private func setupLiveSearch() {
        $searchQuery.debounce(for: .milliseconds(500), scheduler: RunLoop.main).removeDuplicates().sink { [weak self] query in
            guard let self = self else { return }
            if !query.isEmpty { self.displayedPins = []; self.performSearch() }
            else { self.searchResults = []; self.displayedPins = []; self.errorMessage = nil }
        }.store(in: &cancellables)
    }
    
    func performSearch() {
        guard !searchQuery.isEmpty else { return }
        isLoading = true; errorMessage = nil
        let lat = locationService.currentLocation?.latitude ?? -7.2504
        let lon = locationService.currentLocation?.longitude ?? 112.7688
        Task {
            do {
                self.searchResults = try await fourSquareService.searchPlaces(query: searchQuery, latitude: lat, longitude: lon)
                self.isLoading = false
            } catch { self.errorMessage = error.localizedDescription; self.isLoading = false }
        }
    }
    
    func selectPlace(_ place: FSQPlace, isFromAppleMap: Bool = false) {
        self.selectedPlace = place
        self.searchQuery = place.name
        self.displayedPins = isFromAppleMap ? [] : [place]
        self.cameraPosition = .region(MKCoordinateRegion(center: place.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }
    
    func centerToCurrentLocation() {
        let lat = locationService.currentLocation?.latitude ?? -7.2504
        let lon = locationService.currentLocation?.longitude ?? 112.7688
        self.cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    }
    
    func handleAppleMapFeatureClick(_ feature: MapFeature) {
        let tempPlace = FSQPlace(fsq_place_id: UUID().uuidString, name: feature.title ?? "Selected Location", distance: 0, latitude: feature.coordinate.latitude, longitude: feature.coordinate.longitude, location: nil, rating: nil, stats: nil)
        selectPlace(tempPlace, isFromAppleMap: true)
    }
    
    func getIconForCategory(name: String) -> String {
        let lowerName = name.lowercased()
        if lowerName.contains("apotek") || lowerName.contains("hospital") || lowerName.contains("rs ") { return "cross.case.fill" }
        if lowerName.contains("kopi") || lowerName.contains("cafe") || lowerName.contains("makan") || lowerName.contains("seafood") { return "cup.and.saucer.fill" }
        if lowerName.contains("univ") || lowerName.contains("school") { return "graduationcap.fill" }
        if lowerName.contains("hotel") { return "bed.double.fill" }
        return "mappin"
    }
}
