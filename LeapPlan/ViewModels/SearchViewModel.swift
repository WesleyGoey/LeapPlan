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
    @Published var errorMessage: String? = nil
    
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7688), // Default Surabaya
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
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
        errorMessage = nil
        
        // PERUBAHAN UTAMA:
        // Coba ambil lokasi GPS asli pengguna. Jika gagal/belum diizinkan, fallback ke titik tengah peta.
        let searchLatitude = locationService.currentLocation?.latitude ?? mapRegion.center.latitude
        let searchLongitude = locationService.currentLocation?.longitude ?? mapRegion.center.longitude
        
        Task {
            do {
                // Mengirimkan titik GPS pengguna ke Foursquare, sehingga jarak (distance) menjadi valid dari titik user berdiri
                let results = try await fourSquareService.searchPlaces(
                    query: searchQuery,
                    latitude: searchLatitude,
                    longitude: searchLongitude
                )
                self.searchResults = results
                self.isLoading = false
            } catch {
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
    
    // PERUBAHAN UTAMA KEDUA:
    // Tombol "Center to Location" sekarang benar-benar membawa kamera ke titik GPS asli pengguna
    func centerToCurrentLocation() {
        // Ambil koordinat asli, jika tidak ada, baru lempar ke Surabaya
        let lat = locationService.currentLocation?.latitude ?? -7.2504
        let lon = locationService.currentLocation?.longitude ?? 112.7688
        
        self.mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}
