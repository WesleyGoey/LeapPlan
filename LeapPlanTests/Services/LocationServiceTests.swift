//
//  LocationServiceTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import XCTest
import CoreLocation
@testable import LeapPlan

final class LocationServiceTests: XCTestCase {
    
    var service: LocationService!
    
    override func setUp() {
        super.setUp()
        // Catatan: Saat diinisialisasi, init() bawaan akan otomatis memanggil requestLocationPermission()
        service = LocationService()
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    func testLocationManager_DidUpdateLocations_UpdatesCurrentLocationOnMainThread() async {
        // Arrange: Siapkan koordinat dummy (contoh: Surabaya)
        let expectedLatitude = -7.2504
        let expectedLongitude = 112.7688
        let mockLocation = CLLocation(latitude: expectedLatitude, longitude: expectedLongitude)
        let locations = [mockLocation]
        
        // Act: Simulasikan sistem iOS/CLLocationManager mengirimkan pembaruan lokasi ke delegate
        service.locationManager(CLLocationManager(), didUpdateLocations: locations)
        
        // Karena pembaruan di kode kamu dibungkus dalam DispatchQueue.main.async,
        // kita wajib memberikan jeda mikro (0.1 detik) agar run loop Main Thread sempat memproses nilainya.
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert: Pastikan data koordinat berhasil masuk dan cocok
        XCTAssertNotNil(service.currentLocation, "currentLocation harusnya tidak nil setelah mendapatkan update.")
        XCTAssertEqual(service.currentLocation?.latitude, expectedLatitude, "Latitude tidak cocok.")
        XCTAssertEqual(service.currentLocation?.longitude, expectedLongitude, "Longitude tidak cocok.")
    }
    
    func testLocationManager_DidFailWithError_DoesNotCrash() {
        // Arrange: Siapkan error simulasi (misal: GPS dimatikan atau tidak mendapat sinyal)
        let mockError = NSError(domain: "CLErrorDomain", code: CLError.locationUnknown.rawValue, userInfo: nil)
        
        // Act & Assert: Pastikan ketika terjadi kegagalan sinyal GPS, fungsi tidak membuat aplikasi crash
        XCTAssertNoThrow(
            service.locationManager(CLLocationManager(), didFailWithError: mockError),
            "Fungsi didFailWithError harusnya menangani error secara aman tanpa crash."
        )
    }
}
