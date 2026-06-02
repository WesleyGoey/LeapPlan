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
    @Published var addSearchResults: [FSQPlace] = [] // State untuk Pencarian Tempat
    
    private let tripRepository: TripRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let tripGenService: TripGenerationServiceProtocol
    private let fourSquareService: FourSquareServiceProtocol
    
    init(
        trip: Trip,
        tripRepository: TripRepositoryProtocol = TripRepository(),
        authService: AuthServiceProtocol = AuthService(),
        tripGenService: TripGenerationServiceProtocol = TripGenerationService(),
        fourSquareService: FourSquareServiceProtocol = FourSquareService()
    ) {
        self.trip = trip
        self.tripRepository = tripRepository
        self.authService = authService
        self.tripGenService = tripGenService
        self.fourSquareService = fourSquareService
    }
    
    private var activeUserID: String {
        return authService.getCurrentUserID() ?? "dummy_user_123"
    }
    
    var currentDayPlan: DayPlan? {
        guard dayPlans.indices.contains(selectedDayIndex) else { return nil }
        return dayPlans[selectedDayIndex]
    }
    
    func searchPlacesAroundCity(query: String) {
        guard query.count > 2 else {
            self.addSearchResults = []
            return
        }
        
        let city = trip.locationName
        guard !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { self.addSearchResults = []; return }
        Task {
            do {
                // Pencarian Foursquare yang dikunci pada kota trip
                let results = try await fourSquareService.fetchPlaces(near: city, categoryID: "", limit: 10)
                // Filter hasil berdasarkan query user
                self.addSearchResults = results.filter { $0.name.localizedCaseInsensitiveContains(query) }
            } catch {
                print("Search error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - LOAD DATA & ROUTE
    func loadDayPlans() {
        guard let tripID = trip.id else { return }
        isLoading = true
        Task {
            do {
                let fetchedPlans = try await tripRepository.fetchDayPlans(forTripID: tripID, userID: activeUserID)
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
        dayPlans[selectedDayIndex].destinations.removeAll { $0.id == destID }
        saveCurrentDayPlanOrder()
    }
    
    private func saveCurrentDayPlanOrder() {
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
    
    // MARK: - EDIT TRIP (DYNAMIC DAY TABS)
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
            } else if dayPlans.count < totalDays {
                for i in (dayPlans.count + 1)...totalDays {
                    guard let newDate = calendar.date(byAdding: .day, value: i - 1, to: calendar.startOfDay(for: startDate)) else { continue }
                    let newPlan = DayPlan(id: UUID().uuidString, dayNumber: i, date: newDate, destinations: [])
                    try await tripRepository.saveDayPlan(newPlan, forTripID: tripID, userID: userID)
                }
            }
            
            // RELOAD SEMUA DATA AGAR TAB DAY 2, DAY 3, DLL LANGSUNG MUNCUL
            self.loadDayPlans()
            
        } catch {
            print("Error updating trip: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    func saveImageLocally(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.6) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url.absoluteString
        } catch {
            print("Gagal save gambar: \(error)")
            return nil
        }
    }
    
    // MARK: - GENERATE 1 RANDOM PLACE
    // FUNGSI YANG SEBELUMNYA ERROR KARENA BELUM ADA
    func generateOneRandomPlace() {
        guard dayPlans.indices.contains(selectedDayIndex) else { return }
        isLoading = true
        
        Task {
            do {
                let placeCategories = "16000,10027,10055,16032,10044"
                var availablePlaces = try await fourSquareService.fetchPlaces(near: trip.locationName, categoryID: placeCategories, limit: 30)
                
                let invalidWords = ["toko", "store", "shop", "mart", "market", "pasar", "supermarket", "indomaret", "alfamart", "masjid", "vihara", "gereja", "pura", "temple", "shrine", "bank", "atm", "hotel", "penginapan", "kost", "resto", "cafe", "warung", "bakso", "soto", "nasi", "mie", "rs", "klinik", "hospital", "xxi", "cgv", "bioskop"]
                availablePlaces.removeAll { place in
                    let lowerName = place.name.lowercased()
                    return invalidWords.contains(where: { lowerName.contains($0) })
                }
                
                let existingIDs = Set(dayPlans[selectedDayIndex].destinations.compactMap { $0.foursquareID })
                availablePlaces.removeAll { existingIDs.contains($0.fsq_place_id) }
                
                if let randomPlace = availablePlaces.randomElement() {
                    let newDest = TripDestination(
                        id: UUID().uuidString,
                        name: randomPlace.name,
                        category: "Objek Wisata",
                        foursquareID: randomPlace.fsq_place_id,
                        latitude: randomPlace.latitude ?? 0.0,
                        longitude: randomPlace.longitude ?? 0.0,
                        orderIndex: dayPlans[selectedDayIndex].destinations.count,
                        stayDurationMinutes: 120, // Default 2 jam
                        transitTimeToNextMinutes: 30
                    )
                    dayPlans[selectedDayIndex].destinations.append(newDest)
                    saveCurrentDayPlanOrder()
                }
            } catch {
                print("Generate error: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    // MARK: - LIVE SEARCH UNTUK ADD / EDIT PLACE
    func searchPlaceForAdding(query: String) {
        guard query.count > 2 else {
            addSearchResults = []
            return
        }
        
        let city = trip.locationName
        Task {
            do {
                guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let url = URL(string: "https://api.foursquare.com/v3/places/search?near=\(encodedCity)&query=\(encodedQuery)&limit=15") else { return }
                
                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "accept")
                
                request.addValue("RAD1ODGEX4S2UKH55GHDYYEMLWQMVBWPMLEEADELCIKAINWY", forHTTPHeaderField: "Authorization")
                
                let (data, _) = try await URLSession.shared.data(for: request)
                struct FSQSearchResponse: Codable { let results: [FSQPlace] }
                let fsqResponse = try JSONDecoder().decode(FSQSearchResponse.self, from: data)
                
                await MainActor.run { self.addSearchResults = fsqResponse.results }
            } catch {
                print("Error searching places: \(error)")
            }
        }
    }
    
    // MARK: - ADD & UPDATE DESTINATIONS
    func addManualDestination(name: String, category: String, durationMinutes: Int, place: FSQPlace?) {
        guard dayPlans.indices.contains(selectedDayIndex) else { return }
        
        let newDest = TripDestination(
            id: UUID().uuidString,
            name: name,
            category: category,
            foursquareID: place?.fsq_place_id,
            latitude: place?.latitude ?? 0.0,
            longitude: place?.longitude ?? 0.0,
            orderIndex: dayPlans[selectedDayIndex].destinations.count,
            stayDurationMinutes: durationMinutes,
            transitTimeToNextMinutes: 30
        )
        dayPlans[selectedDayIndex].destinations.append(newDest)
        saveCurrentDayPlanOrder()
    }
    
    func updateDestination(id: String, newName: String, category: String, newDuration: Int, place: FSQPlace?) {
        guard dayPlans.indices.contains(selectedDayIndex) else { return }
        
        if let index = dayPlans[selectedDayIndex].destinations.firstIndex(where: { $0.id == id }) {
            dayPlans[selectedDayIndex].destinations[index].name = newName
            dayPlans[selectedDayIndex].destinations[index].category = category
            dayPlans[selectedDayIndex].destinations[index].stayDurationMinutes = newDuration
            
            if let newPlace = place {
                dayPlans[selectedDayIndex].destinations[index].foursquareID = newPlace.fsq_place_id
                dayPlans[selectedDayIndex].destinations[index].latitude = newPlace.latitude ?? 0.0
                dayPlans[selectedDayIndex].destinations[index].longitude = newPlace.longitude ?? 0.0
            }
            saveCurrentDayPlanOrder()
        }
    }
}

