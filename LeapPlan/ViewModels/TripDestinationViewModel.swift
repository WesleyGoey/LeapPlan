//
//  TripDestinationViewModel.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import MapKit
import Combine
import SwiftUI

@MainActor
class TripDestinationViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var dayPlans: [DayPlan] = []
    @Published var selectedDayIndex: Int = 0 { didSet { calculateActualDrivingRoutes() } }
    
    @Published var actualRoutes: [MKRoute] = []
    @Published var isLoading: Bool = false
    @Published var addSearchResults: [FSQPlace] = []
    
    private let firestoreRepo: FirestoreRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let tripDestinationService: TripDestinationServiceProtocol
    private let fourSquareService: FourSquareServiceProtocol
    private let tripService: TripServiceProtocol
    
    init(trip: Trip,
         firestoreRepo: FirestoreRepositoryProtocol? = nil,
         authService: AuthServiceProtocol? = nil,
         tripDestinationService: TripDestinationServiceProtocol? = nil,
         fourSquareService: FourSquareServiceProtocol? = nil,
         tripService: TripServiceProtocol? = nil) {
        self.trip = trip
        self.firestoreRepo = firestoreRepo ?? FirestoreRepository()
        self.authService = authService ?? AuthService()
        self.tripDestinationService = tripDestinationService ?? TripDestinationService()
        self.fourSquareService = fourSquareService ?? FourSquareService()
        self.tripService = tripService ?? TripService()
    }
    
    private var activeUserID: String { return authService.getCurrentUserID() ?? "dummy_user_123" }
    
    var currentDayPlan: DayPlan? {
        guard dayPlans.indices.contains(selectedDayIndex) else { return nil }
        return dayPlans[selectedDayIndex]
    }
    
    // MARK: - LOAD DATA & ROUTE
    func loadDayPlans() {
        guard let tripID = trip.id else { return }
        isLoading = true
        Task {
            do {
                let fetchedPlans = try await firestoreRepo.fetchDayPlans(forTripID: tripID, userID: activeUserID)
                self.dayPlans = fetchedPlans.sorted(by: { $0.dayNumber < $1.dayNumber })
                calculateActualDrivingRoutes()
                self.isLoading = false
            } catch {
                print("Error loading day plans: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
    
    func calculateActualDrivingRoutes() {
        guard dayPlans.indices.contains(selectedDayIndex) else { self.actualRoutes = []; return }
        let destinations = dayPlans[selectedDayIndex].destinations
        guard destinations.count > 1 else { self.actualRoutes = []; return }
        
        Task {
            var newRoutes: [MKRoute] = []
            var updatedDestinations = destinations
            
            for i in 0..<(destinations.count - 1) {
                let source = CLLocationCoordinate2D(latitude: destinations[i].latitude, longitude: destinations[i].longitude)
                let dest = CLLocationCoordinate2D(latitude: destinations[i+1].latitude, longitude: destinations[i+1].longitude)
                
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: dest))
                request.transportType = .automobile
                
                do {
                    let directions = MKDirections(request: request)
                    let response = try await directions.calculate()
                    if let route = response.routes.first {
                        newRoutes.append(route)
                        updatedDestinations[i].transitTimeToNextMinutes = Int(route.expectedTravelTime / 60)
                    }
                } catch { print("Gagal memuat rute jalan: \(error.localizedDescription)") }
            }
            
            await MainActor.run {
                self.actualRoutes = newRoutes
                self.dayPlans[self.selectedDayIndex].destinations = updatedDestinations
            }
        }
    }
    
    // MARK: - FITUR TIMELINE MENGGUNAKAN SERVICE BARU
    func moveDestination(from source: IndexSet, to destination: Int) {
        guard dayPlans.indices.contains(selectedDayIndex), let tripID = trip.id else { return }
        dayPlans[selectedDayIndex].destinations.move(fromOffsets: source, toOffset: destination)
        
        Task {
            do {
                try await tripDestinationService.saveReorderedDestinations(dayPlan: dayPlans[selectedDayIndex], tripID: tripID, userID: activeUserID)
                calculateActualDrivingRoutes()
            } catch { print("Reorder gagal: \(error)") }
        }
    }
    
    func deleteDestination(destID: String) {
        guard dayPlans.indices.contains(selectedDayIndex), let tripID = trip.id else { return }
        dayPlans[selectedDayIndex].destinations.removeAll { $0.id == destID }
        
        Task {
            do {
                try await tripDestinationService.saveReorderedDestinations(dayPlan: dayPlans[selectedDayIndex], tripID: tripID, userID: activeUserID)
                calculateActualDrivingRoutes()
            } catch { print("Delete destinasi gagal: \(error)") }
        }
    }
    
    func getFormattedTime(for destination: TripDestination) -> String {
        guard let plan = currentDayPlan else { return "" }
        return tripDestinationService.calculateTimeline(for: destination, in: plan)
    }
    
    // MARK: - PENCARIAN & PENAMBAHAN LOKAL
    func searchPlacesAroundCity(query: String) {
        guard query.count > 2, !trip.locationName.isEmpty else { self.addSearchResults = []; return }
        Task {
            do {
                let results = try await fourSquareService.fetchPlaces(near: trip.locationName, categoryID: "", limit: 10)
                self.addSearchResults = results.filter { $0.name.localizedCaseInsensitiveContains(query) }
            } catch { print("Search error: \(error.localizedDescription)") }
        }
    }
    
    func addManualDestination(name: String, category: String, durationMinutes: Int, place: FSQPlace?) {
        guard dayPlans.indices.contains(selectedDayIndex), let tripID = trip.id else { return }
        
        let newDest = TripDestination(id: UUID().uuidString, name: name, category: category, foursquareID: place?.fsq_place_id, latitude: place?.latitude ?? 0.0, longitude: place?.longitude ?? 0.0, orderIndex: dayPlans[selectedDayIndex].destinations.count, stayDurationMinutes: durationMinutes, transitTimeToNextMinutes: 30)
        
        dayPlans[selectedDayIndex].destinations.append(newDest)
        Task {
            try? await tripDestinationService.saveReorderedDestinations(dayPlan: dayPlans[selectedDayIndex], tripID: tripID, userID: activeUserID)
            calculateActualDrivingRoutes()
        }
    }
    
    // MARK: - EDIT META TRIP (Dates/Image)
    func updateTripDetails(title: String, startDate: Date, endDate: Date, coverImageUrl: String) async {
        isLoading = true
        var updatedTrip = trip
        updatedTrip.title = title
        updatedTrip.startDate = startDate
        updatedTrip.endDate = endDate
        updatedTrip.coverImageUrl = coverImageUrl.isEmpty ? nil : coverImageUrl // Kosong berarti hapus gambar
        
        guard let tripID = updatedTrip.id else { return }
        let userID = activeUserID
        
        do {
            try await firestoreRepo.updateTrip(updatedTrip, forUserID: userID)
            self.trip = updatedTrip
            
            let components = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: startDate), to: Calendar.current.startOfDay(for: endDate))
            let totalDays = max(1, (components.day ?? 0) + 1)
            
            if dayPlans.count > totalDays {
                for plan in Array(dayPlans[totalDays...]) {
                    if let pid = plan.id { try await firestoreRepo.deleteDayPlan(planID: pid, tripID: tripID, userID: userID) }
                }
            } else if dayPlans.count < totalDays {
                for i in (dayPlans.count + 1)...totalDays {
                    guard let newDate = Calendar.current.date(byAdding: .day, value: i - 1, to: Calendar.current.startOfDay(for: startDate)) else { continue }
                    try await firestoreRepo.saveDayPlan(DayPlan(id: UUID().uuidString, dayNumber: i, date: newDate, destinations: []), forTripID: tripID, userID: userID)
                }
            }
            self.loadDayPlans()
        } catch { print("Update failed: \(error)"); isLoading = false }
    }
    
    func convertImageToBase64String(image: UIImage) -> String? {
        return Base64Helper.encode(image)
    }
//    
//    func generateOneRandomPlace() {
//        // Biarkan kosong jika tidak digunakan, atau isi sesuai logika aslinya
//    }
}
