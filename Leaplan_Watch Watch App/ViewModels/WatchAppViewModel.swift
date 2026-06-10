//
//  WatchAppViewModel.swift
//  Leaplan_Watch Watch App
//
//  Created by Wesley Goey on 10/06/26.
//

import Combine
import Foundation
import SwiftUI


@MainActor
final class WatchAppViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var trips: [Trip] = []
    @Published var isSyncing: Bool = false

    private let sessionManager: WatchSessionManager
    private var cancellables = Set<AnyCancellable>()

    init(sessionManager: WatchSessionManager? = nil) {
        self.sessionManager = sessionManager ?? WatchSessionManager()

        self.sessionManager.$isLoggedIn
            .receive(on: RunLoop.main)
            .assign(to: \.isLoggedIn, on: self)
            .store(in: &cancellables)

        self.sessionManager.$syncedTrips
            .receive(on: RunLoop.main)
            .sink { [weak self] newTrips in
                guard let self = self else { return }
                self.trips = newTrips
                    .filter { $0.status == .ongoing || $0.status == .upcoming }
                    .sorted { trip1, trip2 in
                        let order1 = trip1.status == .ongoing ? 0 : 1
                        let order2 = trip2.status == .ongoing ? 0 : 1
                        
                        if order1 != order2 {
                            return order1 < order2
                        } else {
                            return trip1.startDate < trip2.startDate
                        }
                    }
            }
            .store(in: &cancellables)
    }

    // MARK: - Trigger Manual Sync
    func triggerManualSync() {
        guard !isSyncing else { return }

        isSyncing = true
        sessionManager.sendSyncRequest()
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            self.isSyncing = false
        }
    }
}

extension WatchAppViewModel {
    static func mock(isLoggedIn: Bool = true, isSyncing: Bool = false, trips: [Trip] = []) -> WatchAppViewModel {
        let vm = WatchAppViewModel(sessionManager: WatchSessionManager())
        vm.isLoggedIn = isLoggedIn
        vm.isSyncing = isSyncing
        vm.trips = trips
        return vm
    }
}
