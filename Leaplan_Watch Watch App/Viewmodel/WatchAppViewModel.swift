//
//  WatchAppViewModel.swift
//  Leaplan_Watch Watch App
//

import Combine
import Foundation
import SwiftUI

// MARK: - WatchAppViewModel

@MainActor
final class WatchAppViewModel: ObservableObject {

    // MARK: - Published State

    @Published var isLoggedIn: Bool = false
    @Published var trips: [Trip] = []
    @Published var isSyncing: Bool = false

    // MARK: - Dependencies

    private let sessionManager: WatchSessionManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(sessionManager: WatchSessionManager = WatchSessionManager()) {
        self.sessionManager = sessionManager

        // Observe session manager state
        sessionManager.$isLoggedIn
            .receive(on: RunLoop.main)
            .assign(to: \.isLoggedIn, on: self)
            .store(in: &cancellables)

        sessionManager.$syncedTrips
            .receive(on: RunLoop.main)
            .assign(to: \.trips, on: self)
            .store(in: &cancellables)
    }

    // MARK: - Actions

    /// Triggers a manual sync and provides 1-second visual feedback.
    func triggerManualSync() {
        guard !isSyncing else { return }

        isSyncing = true
        sessionManager.sendSyncRequest()

        // Brief delay for visual feedback
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            self.isSyncing = false
        }
    }
}

// MARK: - Previews Support

extension WatchAppViewModel {
    /// Creates a mock view model for SwiftUI previews
    static func mock(isLoggedIn: Bool = true, isSyncing: Bool = false, trips: [Trip] = []) -> WatchAppViewModel {
        let vm = WatchAppViewModel(sessionManager: WatchSessionManager()) // Session manager won't do anything in previews
        vm.isLoggedIn = isLoggedIn
        vm.isSyncing = isSyncing
        vm.trips = trips
        return vm
    }
}
