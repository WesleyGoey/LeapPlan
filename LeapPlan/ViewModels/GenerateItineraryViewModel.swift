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
    
    @Published var searchResults: [String] = []
    @Published var isShowingDropdown: Bool = false
    
    private let foursquareService: FourSquareServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(foursquareService: FourSquareServiceProtocol = FourSquareService()) {
        self.foursquareService = foursquareService
        updateDailyPreferences()
        
        $destination
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.performFoursquareSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func performFoursquareSearch(query: String) {
        guard query.count > 2 else {
            self.searchResults = []
            self.isShowingDropdown = false
            return
        }
        
        Task {
            do {
                let results = try await foursquareService.autocompleteLocation(query: query)
                self.searchResults = results.map { $0.name }
                self.isShowingDropdown = !results.isEmpty
            } catch {
                print("Foursquare Error: \(error.localizedDescription)")
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
