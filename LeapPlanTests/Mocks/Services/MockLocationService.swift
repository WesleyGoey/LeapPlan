//
//  MockLocationService.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 03/06/26.
//


import Foundation
import CoreLocation
import Combine
@testable import LeapPlan

class MockLocationService: ObservableObject, LocationServiceProtocol {
    // Sesuai dengan protocol, kita harus punya property ini
    @Published var currentLocation: CLLocationCoordinate2D?
    
    // Fungsi untuk menyuntikkan data dummy ke ViewModel
    func setDummyLocation(lat: Double, lon: Double) {
        self.currentLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    // Stub methods lainnya (jika ada di protocol)
    func requestLocationPermission() {
        // Tidak melakukan apa-apa di mock
    }
}