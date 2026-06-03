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
    @Published var selectedDayIndex: Int = 0 { didSet { calculateRouteForSelectedDay() } }
    
    @Published var mapRoute: MKPolyline?
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
                calculateRouteForSelectedDay()
                self.isLoading = false
            } catch {
                print("Error loading day plans: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
    
    func calculateRouteForSelectedDay() {
        guard dayPlans.indices.contains(selectedDayIndex) else { self.mapRoute = nil; return }
        let destinations = dayPlans[selectedDayIndex].destinations
        guard destinations.count > 1 else { self.mapRoute = nil; return }
        
        var coordinates = destinations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        self.mapRoute = MKPolyline(coordinates: &coordinates, count: coordinates.count)
    }
    
    // MARK: - FITUR TIMELINE MENGGUNAKAN SERVICE BARU
    func moveDestination(from source: IndexSet, to destination: Int) {
        guard dayPlans.indices.contains(selectedDayIndex), let tripID = trip.id else { return }
        dayPlans[selectedDayIndex].destinations.move(fromOffsets: source, toOffset: destination)
        
        Task {
            do {
                try await tripDestinationService.saveReorderedDestinations(dayPlan: dayPlans[selectedDayIndex], tripID: tripID, userID: activeUserID)
                calculateRouteForSelectedDay()
            } catch { print("Reorder gagal: \(error)") }
        }
    }
    
    func deleteDestination(destID: String) {
        guard dayPlans.indices.contains(selectedDayIndex), let tripID = trip.id else { return }
        dayPlans[selectedDayIndex].destinations.removeAll { $0.id == destID }
        
        Task {
            do {
                try await tripDestinationService.saveReorderedDestinations(dayPlan: dayPlans[selectedDayIndex], tripID: tripID, userID: activeUserID)
                calculateRouteForSelectedDay()
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
        Task { try? await tripDestinationService.saveReorderedDestinations(dayPlan: dayPlans[selectedDayIndex], tripID: tripID, userID: activeUserID); calculateRouteForSelectedDay() }
    }
    
    // MARK: - EDIT META TRIP (Dates/Image)
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
    
    // MENGGUNAKAN BASE64 HELPER EKSKLUSIF
    func convertImageToBase64String(image: UIImage) -> String? {
        return Base64Helper.encode(image)
    }
}
