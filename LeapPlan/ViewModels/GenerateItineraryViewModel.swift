//
//  GenerateItineraryViewModel.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class GenerateItineraryViewModel: ObservableObject {
    @Published var destination: String = ""
    @Published var startDate: Date = Date() { didSet { updateDailyPreferences() } }
    @Published var endDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date())! { didSet { updateDailyPreferences() } }
    
    @Published var dailyPreferences: [DailyPreference] = []
    @Published var selectedDayNumber: Int = 1
    
    // Status Autocomplete Foursquare
    @Published var searchResults: [FSQPlace] = []
    @Published var isShowingDropdown: Bool = false
    
    private let foursquareService: FourSquareServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(foursquareService: FourSquareServiceProtocol = MockFourSquareService()) {
        self.foursquareService = foursquareService
        updateDailyPreferences()
        
        // Memantau setiap ketikan user di TextField dengan jeda 600 milidetik
        $destination
            .removeDuplicates()
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        // Hanya mencari jika ketikan lebih dari 2 huruf
        guard query.count > 2 else {
            searchResults = []
            isShowingDropdown = false
            return
        }
        
        Task {
            do {
                let results = try await foursquareService.autocompleteLocation(query: query)
                self.searchResults = results
                self.isShowingDropdown = !results.isEmpty
            } catch {
                print("Error Autocomplete Foursquare: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateDailyPreferences() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        
        if end < start { self.endDate = start; return }
        
        let components = calendar.dateComponents([.day], from: start, to: end)
        let totalDays = max(1, (components.day ?? 0) + 1)
        
        if dailyPreferences.count < totalDays {
            for i in (dailyPreferences.count + 1)...totalDays {
                dailyPreferences.append(DailyPreference(dayNumber: i, meals: 3, places: 4))
            }
        } else if dailyPreferences.count > totalDays {
            dailyPreferences.removeLast(dailyPreferences.count - totalDays)
        }
        
        if selectedDayNumber > totalDays { selectedDayNumber = totalDays }
    }
}
