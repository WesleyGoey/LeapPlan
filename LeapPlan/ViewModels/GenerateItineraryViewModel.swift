//
//  GenerateItineraryViewModel.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import Foundation
import Combine
import SwiftUI
import MapKit // PENTING: Tambahkan MapKit

@MainActor
class GenerateItineraryViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var destination: String = ""
    @Published var startDate: Date = Date() { didSet { updateDailyPreferences() } }
    @Published var endDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date())! { didSet { updateDailyPreferences() } }
    
    @Published var dailyPreferences: [DailyPreference] = []
    @Published var selectedDayNumber: Int = 1
    
    // Status Autocomplete MapKit (Sekarang berupa Array String)
    @Published var searchResults: [String] = []
    @Published var isShowingDropdown: Bool = false
    
    private var completer: MKLocalSearchCompleter
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init() // Wajib dipanggil karena kita mewarisi NSObject
        
        self.completer.delegate = self
        
        updateDailyPreferences()
        
        // Memantau ketikan user
        $destination
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // Lebih responsif (300ms)
            .sink { [weak self] query in
                guard let self = self else { return }
                if query.count > 1 {
                    // Memicu Apple MapKit untuk mencari kota
                    self.completer.queryFragment = query
                } else {
                    self.searchResults = []
                    self.isShowingDropdown = false
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Saat Apple Maps menemukan kota, kita format menjadi "Nama, Negara" (Contoh: "Bali, Indonesia")
        self.searchResults = completer.results.map { result in
            if result.subtitle.isEmpty { return result.title }
            return "\(result.title), \(result.subtitle)"
        }
        self.isShowingDropdown = !self.searchResults.isEmpty
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("MapKit Autocomplete Error: \(error.localizedDescription)")
    }
    
    // MARK: - Helper
    private func updateDailyPreferences() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        
        if end < start {
            self.endDate = start
            return
        }
        
        let components = calendar.dateComponents([.day], from: start, to: end)
        let totalDays = max(1, (components.day ?? 0) + 1)
        
        if dailyPreferences.count < totalDays {
            for i in (dailyPreferences.count + 1)...totalDays {
                dailyPreferences.append(DailyPreference(dayNumber: i, meals: 3, places: 4))
            }
        } else if dailyPreferences.count > totalDays {
            dailyPreferences.removeLast(dailyPreferences.count - totalDays)
        }
        
        if selectedDayNumber > totalDays {
            selectedDayNumber = totalDays
        }
    }
}
