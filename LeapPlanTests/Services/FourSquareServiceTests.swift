//
//  FourSquareServiceTests.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import XCTest
@testable import LeapPlan

final class FourSquareServiceTests: XCTestCase {
    var service: FourSquareService!
    
    override func setUp() {
        super.setUp()
        service = FourSquareService()
    }
    
    // Kita tidak mengetes data dari API, tapi kita mengetes apakah Service 
    // bisa diinisialisasi dan tidak crash. 
    func testService_Initialization() {
        XCTAssertNotNil(service, "Service harus berhasil diinisialisasi")
    }
    
    // Testing ini memastikan tidak ada crash saat memanggil fungsi dengan parameter kosong
    func testFetchTrendingPlaces_EmptyCity_DoesNotCrash() async {
        do {
            _ = try await service.fetchTrendingPlaces(city: "")
        } catch {
            // Kita mengharapkan error (karena API key atau city kosong), 
            // tapi yang penting aplikasi tidak crash.
            XCTAssertNotNil(error)
        }
    }
}