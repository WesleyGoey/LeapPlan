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
    
    // MARK: - BYPASS LOGIN UNTUK TESTING
    private var activeUserID: String {
        return authService.getCurrentUserID() ?? "dummy_user_123"
    }
    
    var currentDayPlan: DayPlan? {
        guard dayPlans.indices.contains(selectedDayIndex) else { return nil }
        return dayPlans[selectedDayIndex]
    }
    
    // MARK: - LOAD DATA
    func loadDayPlans() {
        guard let tripID = trip.id else { return }
        let userID = activeUserID // Menggunakan ID Bypass
        
        isLoading = true
        
        Task {
            do {
                let fetchedPlans = try await tripRepository.fetchDayPlans(forTripID: tripID, userID: userID)
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
        var coordinates = destinations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        self.mapRoute = MKPolyline(coordinates: &coordinates, count: coordinates.count)
    }
    
    // MARK: - FITUR TIMELINE (Reorder, Delete)
    func moveDestination(from source: IndexSet, to destination: Int) {
        guard dayPlans.indices.contains(selectedDayIndex) else { return }
        dayPlans[selectedDayIndex].destinations.move(fromOffsets: source, toOffset: destination)
        saveCurrentDayPlanOrder()
    }
    
    func deleteDestination(destID: String) {
        guard dayPlans.indices.contains(selectedDayIndex) else { return }
        // Hapus destinasi dari array lokal
        dayPlans[selectedDayIndex].destinations.removeAll { $0.id == destID }
        saveCurrentDayPlanOrder()
    }
    
    private func saveCurrentDayPlanOrder() {
        // Susun ulang nomor urutannya
        for (index, _) in dayPlans[selectedDayIndex].destinations.enumerated() {
            dayPlans[selectedDayIndex].destinations[index].orderIndex = index
        }
        
        guard let tripID = trip.id else { return }
        let updatedDayPlan = dayPlans[selectedDayIndex]
        let userID = activeUserID
        
        Task {
            do {
                try await tripRepository.saveDayPlan(updatedDayPlan, forTripID: tripID, userID: userID)
                calculateRouteForSelectedDay()
            } catch {
                print("Gagal menyimpan perubahan destinasi: \(error.localizedDescription)")
            }
        }
    }
    
    func calculateTime(for destination: TripDestination, in dayPlan: DayPlan) -> String {
        guard let index = dayPlan.destinations.firstIndex(where: { $0.id == destination.id }) else { return "" }
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
    
    // MARK: - FITUR EDIT TRIP
    func updateTripDetails(title: String, startDate: Date, endDate: Date, coverImageUrl: String) async {
        isLoading = true
        var updatedTrip = trip
        updatedTrip.title = title
        updatedTrip.startDate = startDate
        updatedTrip.endDate = endDate
        if !coverImageUrl.isEmpty { updatedTrip.coverImageUrl = coverImageUrl }
        
        guard let tripID = updatedTrip.id else { return }
        let userID = activeUserID
        
        do {
            try await tripRepository.updateTrip(updatedTrip, forUserID: userID)
            self.trip = updatedTrip
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: calendar.startOfDay(for: endDate))
            let totalDays = max(1, (components.day ?? 0) + 1)
            
            if dayPlans.count > totalDays {
                let plansToDelete = Array(dayPlans[totalDays...])
                for plan in plansToDelete {
                    if let planID = plan.id {
                        try await tripRepository.deleteDayPlan(planID: planID, tripID: tripID, userID: userID)
                    }
                }
                self.dayPlans.removeLast(dayPlans.count - totalDays)
                if selectedDayIndex >= totalDays { selectedDayIndex = totalDays - 1 }
            } else if dayPlans.count < totalDays {
                for i in (dayPlans.count + 1)...totalDays {
                    guard let newDate = calendar.date(byAdding: .day, value: i - 1, to: calendar.startOfDay(for: startDate)) else { continue }
                    let newPlan = DayPlan(id: UUID().uuidString, dayNumber: i, date: newDate, destinations: [])
                    try await tripRepository.saveDayPlan(newPlan, forTripID: tripID, userID: userID)
                    self.dayPlans.append(newPlan)
                }
            }
            isLoading = false
            calculateRouteForSelectedDay()
        } catch {
            print("Error updating trip: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // HELPER UNTUK MENYIMPAN GAMBAR KE FOLDER LOKAL HP
    func saveImageLocally(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.6) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url.absoluteString // Menghasilkan format "file://..."
        } catch {
            print("Gagal save gambar: \(error)")
            return nil
        }
    }
}
