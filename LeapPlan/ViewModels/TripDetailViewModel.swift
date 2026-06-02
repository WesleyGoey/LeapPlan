//
//  TripDetailViewModel.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import MapKit
import Combine
import SwiftUI

@MainActor
class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var dayPlans: [DayPlan] = []
    @Published var selectedDayIndex: Int = 0 {
        didSet {
            calculateRouteForSelectedDay()
        }
    }
    
    @Published var mapRoute: MKPolyline?
    @Published var isLoading: Bool = false
    
    private let tripRepository: TripRepositoryProtocol
    private let authService: AuthServiceProtocol
    
    init(trip: Trip, tripRepository: TripRepositoryProtocol = TripRepository(), authService: AuthServiceProtocol = AuthService()) {
        self.trip = trip
        self.tripRepository = tripRepository
        self.authService = authService
    }
    
    // MARK: - 1. FIX FIX: Properti Pembantu untuk Mendapatkan Jadwal Hari Aktif
    var currentDayPlan: DayPlan? {
        guard dayPlans.indices.contains(selectedDayIndex) else { return nil }
        return dayPlans[selectedDayIndex]
    }
    
    func loadDayPlans() {
        guard let tripID = trip.id, let userID = authService.getCurrentUserID() else { return }
        isLoading = true
        
        Task {
            do {
                let fetchedPlans = try await tripRepository.fetchDayPlans(forTripID: tripID, userID: userID)
                // Urutkan berdasarkan hari agar tidak acak-acakan di UI
                self.dayPlans = fetchedPlans.sorted(by: { $0.dayNumber < $1.dayNumber })
                calculateRouteForSelectedDay()
                self.isLoading = false
            } catch {
                print("Error loading day plans: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
    
    func calculateRouteForSelectedDay() {
        guard dayPlans.indices.contains(selectedDayIndex) else {
            self.mapRoute = nil
            return
        }
        
        let destinations = dayPlans[selectedDayIndex].destinations
        guard destinations.count > 1 else {
            self.mapRoute = nil
            return
        }
        
        // Konversi destinasi menjadi titik koordinat MapKit
        var coordinates = destinations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        self.mapRoute = MKPolyline(coordinates: &coordinates, count: coordinates.count)
    }
    
    // MARK: - 2. FIX FIX: Logika Geser Urutan (Drag and Drop Reorder) untuk TripDetailView
    func moveDestination(from source: IndexSet, to destination: Int) {
        guard dayPlans.indices.contains(selectedDayIndex) else { return }
        
        // Geser data di memori lokal HP agar UI langsung berubah mulus
        dayPlans[selectedDayIndex].destinations.move(fromOffsets: source, toOffset: destination)
        
        // Setel ulang orderIndex-nya dari 0 lagi
        for (index, _) in dayPlans[selectedDayIndex].destinations.enumerated() {
            dayPlans[selectedDayIndex].destinations[index].orderIndex = index
        }
        
        // Simpan urutan baru ini secara permanen ke Firebase Firestore
        guard let userID = authService.getCurrentUserID(), let tripID = trip.id else { return }
        let updatedDayPlan = dayPlans[selectedDayIndex]
        
        Task {
            do {
                try await tripRepository.saveDayPlan(updatedDayPlan, forTripID: tripID, userID: userID)
            } catch {
                print("Gagal menyimpan urutan baru ke Firebase: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 3. FIX FIX: Kalkulator Waktu Linimasa (Timeline Card) otomatis
    func calculateTime(for destination: TripDestination, in dayPlan: DayPlan) -> String {
        guard let index = dayPlan.destinations.firstIndex(where: { $0.id == destination.id }) else { return "" }
        
        // Rencana harian kita asumsikan selalu dimulai pukul 09:00 AM (540 menit dari jam 00:00)
        var totalMinutes = 9 * 60
        
        for i in 0..<index {
            let prevDest = dayPlan.destinations[i]
            totalMinutes += prevDest.stayDurationMinutes
            totalMinutes += prevDest.transitTimeToNextMinutes ?? 0
        }
        
        let hours = (totalMinutes / 60) % 24
        let minutes = totalMinutes % 60
        let ampm = hours >= 12 ? "PM" : "AM"
        let displayHours = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours)
        
        return String(format: "%02d:%02d %@", displayHours, minutes, ampm)
    }
}
