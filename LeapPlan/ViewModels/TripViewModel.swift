//
//  TripViewModel.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 28/05/26.
//

import Combine
import Foundation
import UIKit

@MainActor
class TripViewModel: ObservableObject {
    // MARK: - STATE LIST TRIP
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - STATE GENERATE/CREATE TRIP
    @Published var destinationForm: String = ""
    @Published var tripNameForm: String = ""
    @Published var startDateForm: Date = Date() {
        didSet { updateDailyPreferences() }
    }
    @Published var endDateForm: Date = Calendar.current.date(
        byAdding: .day,
        value: 2,
        to: Date()
    )!
    { didSet { updateDailyPreferences() } }
    @Published var dailyPreferences: [DailyPreference] = []
    @Published var selectedDayNumber: Int = 1
    @Published var autocompleteResults: [String] = []
    @Published var isShowingDropdown: Bool = false

    private let firestoreRepo: FirestoreRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let tripService: TripServiceProtocol
    private let fourSquareService: FourSquareServiceProtocol
    private let tripDestinationService: TripDestinationServiceProtocol

    private var cancellables = Set<AnyCancellable>()

    init(
        firestoreRepo: FirestoreRepositoryProtocol? = nil,
        authService: AuthServiceProtocol? = nil,
        tripService: TripServiceProtocol? = nil,
        fourSquareService: FourSquareServiceProtocol? = nil,
        tripDestinationService: TripDestinationServiceProtocol? = nil
    ) {

        let safeRepo = firestoreRepo ?? FirestoreRepository()
        self.firestoreRepo = safeRepo
        self.authService = authService ?? AuthService()
        self.tripService = tripService ?? TripService()
        self.fourSquareService = fourSquareService ?? FourSquareService()
        self.tripDestinationService =
            tripDestinationService
            ?? TripDestinationService(firestoreRepo: safeRepo)

        setupGenerateFormLiveSearch()
        updateDailyPreferences()
    }

    var isLoggedIn: Bool { return authService.isLoggedIn }
    private var activeUserID: String {
        return authService.getCurrentUserID() ?? "dummy_user_123"
    }

    private func calculateTripStatus(startDate: Date, endDate: Date)
        -> TripStatus
    {
        let now = Date()
        if now < startDate { return .upcoming }
        if now >= startDate && now <= endDate { return .ongoing }
        return .past
    }

    // MARK: - LOGIKA LIST TRIP (BUG FIX BLANK SHEET)
    func loadUserTrips() {
        guard authService.isLoggedIn else { return }
        let userID = activeUserID
        isLoading = true
        Task {
            do {
                let fetchedTrips = try await firestoreRepo.fetchTrips(
                    forUserID: userID
                )

                self.trips = fetchedTrips.map { trip in
                    var t = trip
                    t.status = calculateTripStatus(
                        startDate: trip.startDate,
                        endDate: trip.endDate
                    )
                    return t
                }.sorted { trip1, trip2 in
                    let statusOrder: [TripStatus: Int] = [.ongoing: 0, .upcoming: 1, .past: 2]
                    let order1 = statusOrder[trip1.status] ?? 3
                    let order2 = statusOrder[trip2.status] ?? 3
                    
                    if order1 != order2 {
                        return order1 < order2
                    } else {
                        // If same status, sort by startDate (closest first for ongoing/upcoming, newest first for past)
                        if trip1.status == .past {
                            return trip1.startDate > trip2.startDate
                        } else {
                            return trip1.startDate < trip2.startDate
                        }
                    }
                }
                self.isLoading = false
                
                // Push updated trips to WatchOS immediately
                Task { @MainActor in
                    IOSWatchSessionManager.shared.syncTrips(trips: self.trips)
                }
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func deleteTrip(tripID: String) {
        let userID = activeUserID
        isLoading = true
        Task {
            do {
                try await firestoreRepo.deleteTrip(
                    tripID: tripID,
                    forUserID: userID
                )
                self.loadUserTrips()
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func updateTripDetails(
        trip: Trip,
        title: String,
        startDate: Date,
        endDate: Date,
        coverImageUrl: String
    ) async {
        isLoading = true
        var updatedTrip = trip
        updatedTrip.title = title
        updatedTrip.startDate = startDate
        updatedTrip.endDate = endDate
        updatedTrip.coverImageUrl = coverImageUrl.isEmpty ? nil : coverImageUrl

        guard let tripID = updatedTrip.id else { return }
        let userID = activeUserID

        do {
            try await firestoreRepo.updateTrip(updatedTrip, forUserID: userID)
            let calendar = Calendar.current
            let components = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: startDate),
                to: calendar.startOfDay(for: endDate)
            )
            let totalDays = max(1, (components.day ?? 0) + 1)
            let existingDayPlans = try await firestoreRepo.fetchDayPlans(
                forTripID: tripID,
                userID: userID
            )

            if existingDayPlans.count > totalDays {
                let plansToDelete = Array(existingDayPlans[totalDays...])
                for plan in plansToDelete {
                    if let planID = plan.id {
                        try await firestoreRepo.deleteDayPlan(
                            planID: planID,
                            tripID: tripID,
                            userID: userID
                        )
                    }
                }
            } else if existingDayPlans.count < totalDays {
                for i in (existingDayPlans.count + 1)...totalDays {
                    guard
                        let newDate = Calendar.current.date(
                            byAdding: .day,
                            value: i - 1,
                            to: Calendar.current.startOfDay(for: startDate)
                        )
                    else { continue }
                    let newPlan = DayPlan(
                        id: UUID().uuidString,
                        dayNumber: i,
                        date: newDate,
                        destinations: []
                    )
                    try await firestoreRepo.saveDayPlan(
                        newPlan,
                        forTripID: tripID,
                        userID: userID
                    )
                }
            }
            await MainActor.run { self.loadUserTrips() }
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    private func setupGenerateFormLiveSearch() {
        $destinationForm.removeDuplicates().debounce(
            for: .milliseconds(500),
            scheduler: RunLoop.main
        ).sink { [weak self] query in
            self?.performFormSearch(query: query)
        }.store(in: &cancellables)
    }

    private func performFormSearch(query: String) {
        guard query.count > 2 else {
            self.autocompleteResults = []
            self.isShowingDropdown = false
            return
        }
        Task {
            do {
                let results = try await fourSquareService.autocompleteLocation(
                    query: query
                )
                self.autocompleteResults = results.map { $0.name }
                self.isShowingDropdown = !results.isEmpty
            } catch { print("Foursquare Error: \(error.localizedDescription)") }
        }
    }

    private func updateDailyPreferences() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDateForm)
        let end = calendar.startOfDay(for: endDateForm)
        if end < start {
            self.endDateForm = start
            return
        }

        let components = calendar.dateComponents([.day], from: start, to: end)
        let totalDays = max(1, (components.day ?? 0) + 1)

        if dailyPreferences.count < totalDays {
            for i in (dailyPreferences.count + 1)...totalDays {
                dailyPreferences.append(
                    DailyPreference(dayNumber: i, meals: 3, places: 4)
                )
            }
        } else if dailyPreferences.count > totalDays {
            dailyPreferences.removeLast(dailyPreferences.count - totalDays)
        }
        if selectedDayNumber > totalDays { selectedDayNumber = totalDays }
    }

    func createManualTrip() async throws -> Trip {
        let userID = activeUserID
        let finalTitle =
            tripNameForm.trimmingCharacters(in: .whitespaces).isEmpty
            ? "\(destinationForm) Trip" : tripNameForm
        var newTrip = Trip(
            title: finalTitle,
            locationName: destinationForm,
            startDate: startDateForm,
            endDate: endDateForm,
            status: .upcoming,
            participantIDs: [userID],
            createdAt: Date(),
            createdBy: userID
        )
        newTrip.coverImageUrl = nil

        let totalDays = dailyPreferences.count
        var emptyDays: [DayPlan] = []
        for i in 1...totalDays {
            if let newDate = Calendar.current.date(
                byAdding: .day,
                value: i - 1,
                to: Calendar.current.startOfDay(for: startDateForm)
            ) {
                emptyDays.append(
                    DayPlan(
                        id: UUID().uuidString,
                        dayNumber: i,
                        date: newDate,
                        destinations: []
                    )
                )
            }
        }

        try await firestoreRepo.saveGeneratedTripWithDayPlans(
            trip: newTrip,
            dayPlans: emptyDays,
            userID: userID
        )
        self.loadUserTrips()
        return newTrip
    }

    func generateRandomTrip() async throws -> Trip {
        let userID = activeUserID
        let prefs = RandomTripPreferences(
            locationName: destinationForm,
            startDate: startDateForm,
            endDate: endDateForm,
            dailyPreferences: dailyPreferences
        )

        let finalTitle =
            tripNameForm.trimmingCharacters(in: .whitespaces).isEmpty
            ? "\(destinationForm) Trip" : tripNameForm  // Cek jika kosong
        var newTrip = Trip(
            title: finalTitle,
            locationName: prefs.locationName,
            startDate: prefs.startDate,
            endDate: prefs.endDate,
            status: .upcoming,
            participantIDs: [userID],
            createdAt: Date(),
            createdBy: userID
        )
        newTrip.coverImageUrl = nil

        let generatedDayPlans = try await tripService.generateRandomItinerary(
            preferences: prefs
        )
        try await firestoreRepo.saveGeneratedTripWithDayPlans(
            trip: newTrip,
            dayPlans: generatedDayPlans,
            userID: userID
        )

        self.loadUserTrips()
        return newTrip
    }

    // MARK: - TOGGLE PLACE LOGIC (IDE CERDASMU)
    func togglePlaceInDay(
        place: FSQPlace,
        trip: Trip,
        dayNum: Int,
        isAdding: Bool
    ) async {
        let userID = activeUserID
        guard let tripID = trip.id else { return }

        do {
            if isAdding {
                try await tripDestinationService.addPlaceToTrip(
                    place: place,
                    targetTrip: trip,
                    selectedDays: [dayNum],
                    userID: userID
                )
            } else {
                try await tripDestinationService.removePlaceFromTrip(
                    placeID: place.fsq_place_id,
                    tripID: tripID,
                    dayNum: dayNum,
                    userID: userID
                )
            }
        } catch {
            print("Gagal sync data ke Firebase: \(error.localizedDescription)")
        }
    }

    func fetchDayPlans(for tripID: String) async -> [DayPlan] {
        do {
            return try await firestoreRepo.fetchDayPlans(
                forTripID: tripID,
                userID: activeUserID
            )
        } catch {
            return []
        }
    }

    // MARK: - RESET FORM
    func resetForm() {
        destinationForm = ""
        tripNameForm = ""
        startDateForm = Date()
        if let defaultEndDate = Calendar.current.date(
            byAdding: .day,
            value: 2,
            to: Date()
        ) {
            endDateForm = defaultEndDate
        }
        autocompleteResults = []
        isShowingDropdown = false
    }

    func clearData() {
        self.trips = []
        self.isLoading = false
        self.errorMessage = nil
    }
}
