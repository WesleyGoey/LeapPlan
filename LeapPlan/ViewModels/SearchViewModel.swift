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
    
    // State baru untuk mengontrol Sheet Add to Itinerary
    @Published var isShowingAddToItinerary: Bool = false
    
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7688),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    private let fourSquareService: FourSquareServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(fourSquareService: FourSquareServiceProtocol? = nil,
         locationService: LocationServiceProtocol? = nil) {
        self.fourSquareService = fourSquareService ?? FourSquareService()
        self.locationService = locationService ?? LocationService()
        
        setupLiveSearch()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.centerToCurrentLocation()
        }
    }
    
    private func setupLiveSearch() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                if !query.isEmpty {
                    self.displayedPins = []
                    self.performSearch()
                } else {
                    self.searchResults = []
                    self.displayedPins = []
                    self.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func performSearch() {
        guard !searchQuery.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        let searchLatitude = locationService.currentLocation?.latitude ?? -7.2504
        let searchLongitude = locationService.currentLocation?.longitude ?? 112.7688
        
        Task {
            do {
                let results = try await fourSquareService.searchPlaces(
                    query: searchQuery, latitude: searchLatitude, longitude: searchLongitude
                )
                self.searchResults = results
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func selectPlace(_ place: FSQPlace, isFromAppleMap: Bool = false) {
        self.selectedPlace = place
        self.searchQuery = place.name
        
        if isFromAppleMap {
            self.displayedPins = []
        } else {
            self.displayedPins = [place]
        }
        
        self.cameraPosition = .region(MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    func centerToCurrentLocation() {
        let lat = locationService.currentLocation?.latitude ?? -7.2504
        let lon = locationService.currentLocation?.longitude ?? 112.7688
        self.cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    // MARK: - DIPINDAH DARI VIEW (Business Logic & Data Formatting)
    
    func handleAppleMapFeatureClick(title: String?, coordinate: CLLocationCoordinate2D) {
        let tempPlace = FSQPlace(
            fsq_place_id: UUID().uuidString,
            name: title ?? "Selected Location",
            distance: 0,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            location: FSQLocation(locality: nil, country: nil),
            rating: nil,
            stats: nil
        )
        self.selectPlace(tempPlace, isFromAppleMap: true)
    }
    
    func getIconForCategory(_ name: String) -> String {
        let lowerName = name.lowercased()
        if lowerName.contains("apotek") || lowerName.contains("hospital") || lowerName.contains("rs ") || lowerName.contains("rumah sakit") { return "cross.case.fill" }
        if lowerName.contains("kopi") || lowerName.contains("cafe") || lowerName.contains("seafood") || lowerName.contains("makan") || lowerName.contains("resto") { return "cup.and.saucer.fill" }
        if lowerName.contains("univ") || lowerName.contains("school") || lowerName.contains("ciputra") { return "graduationcap.fill" }
        if lowerName.contains("hotel") || lowerName.contains("residence") { return "bed.double.fill" }
        return "mappin"
    }
}
