//
//  IOSWatchSessionManager.swift
//  LeapPlan
//
//  Created for iOS to Watch Synchronization
//

import FirebaseAuth
import Foundation
import WatchConnectivity

@MainActor
final class IOSWatchSessionManager: NSObject { // 1. Remove WCSessionDelegate here

    static let shared = IOSWatchSessionManager()

    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private let firestoreRepo = FirestoreRepository()

    override private init() {
        super.init()
    }

    func startSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            print("[IOSWatchSessionManager] WCSession activated.")
        }

        // Listen to global Auth state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener {
            [weak self] _, user in
            guard let self = self else { return }
            let isLoggedIn = (user != nil)

            // Push the login state to the Watch immediately
            self.pushContext(["isLoggedIn": isLoggedIn])

            // If logged in, eagerly push trips as well
            if isLoggedIn, let uid = user?.uid {
                Task {
                    await self.fetchAndSyncTrips(for: uid)
                }
            } else {
                // If logged out, clear trips
                self.pushContext(["tripsJSON": "[]"])
            }
        }
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Outgoing Data
    
    /// Called manually by ViewModels whenever trips change
    func syncTrips(trips: [Trip]) {
        do {
            let dtos = trips.map { trip in
                TripDTO(
                    id: trip.id,
                    title: trip.title,
                    locationName: trip.locationName,
                    startDate: trip.startDate,
                    endDate: trip.endDate,
                    status: trip.status,
                    coverImageUrl: trip.coverImageUrl,
                    participantIDs: trip.participantIDs,
                    totalPlaces: trip.totalPlaces,
                    createdAt: trip.createdAt,
                    createdBy: trip.createdBy
                )
            }
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            let tripsData = try encoder.encode(dtos)

            if let tripsJSON = String(data: tripsData, encoding: .utf8) {
                print(
                    "[IOSWatchSessionManager] Pushing \(dtos.count) trips to Watch"
                )
                pushContext(["tripsJSON": tripsJSON])
            }
        } catch {
            print(
                "[IOSWatchSessionManager] Failed to encode trips for watch: \(error)"
            )
        }
    }

    private func fetchAndSyncTrips(for userID: String) async {
        do {
            let trips = try await firestoreRepo.fetchTrips(forUserID: userID)
            let updatedTrips = self.calculateStatuses(for: trips)
            await MainActor.run {
                self.syncTrips(trips: updatedTrips)
            }
        } catch {
            print(
                "[IOSWatchSessionManager] Failed to fetch eager trips: \(error)"
            )
        }
    }

    fileprivate func calculateStatuses(for trips: [Trip]) -> [Trip] {
        let now = Date()
        return trips.map { trip in
            var t = trip
            if now < t.startDate {
                t.status = .upcoming
            } else if now >= t.startDate && now <= t.endDate {
                t.status = .ongoing
            } else {
                t.status = .past
            }
            return t
        }
    }

    // 2. Moved inside the class scope
    private func pushContext(_ dictionary: [String: Any]) {
        guard WCSession.default.activationState == .activated else { return }

        do {
            try WCSession.default.updateApplicationContext(dictionary)
        } catch {
            print(
                "[IOSWatchSessionManager] Failed to update application context: \(error)"
            )
        }
    }
}

// MARK: - WCSessionDelegate Extension

// 3. Create an extension conforming to the protocol
extension IOSWatchSessionManager: WCSessionDelegate {

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print(
                "[IOSWatchSessionManager] Activation failed: \(error.localizedDescription)"
            )
            return
        }

        if activationState == .activated {
            // Re-sync current auth state
            let isLoggedIn = (Auth.auth().currentUser != nil)

            // We use updateApplicationContext here safely by using Task to capture it
            Task {
                do {
                    try session.updateApplicationContext(["isLoggedIn": isLoggedIn])
                } catch {
                    print(
                        "[IOSWatchSessionManager] Failed to send context upon activation: \(error)"
                    )
                }
            }
        }
    }

#if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        // Required protocol stub
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate if deactivated (e.g. app switching)
        session.activate()
    }
#endif

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        if let request = message["request"] as? String {
            switch request {
            case "fetchLatestData":
                print("[IOSWatchSessionManager] Watch requested fetchLatestData.")

                let isLoggedIn = (Auth.auth().currentUser != nil)
                var replyData: [String: Any] = ["isLoggedIn": isLoggedIn]

                if let uid = Auth.auth().currentUser?.uid {
                    Task { @MainActor in
                        do {
                            // Fixed 'self' reference inside isolated Task
                            let manager = IOSWatchSessionManager.shared
                            let firestore = FirestoreRepository()
                            let trips = try await firestore.fetchTrips(forUserID: uid)
                            let updatedTrips = manager.calculateStatuses(for: trips)

                            let dtos = updatedTrips.map { trip in
                                TripDTO(
                                    id: trip.id,
                                    title: trip.title,
                                    locationName: trip.locationName,
                                    startDate: trip.startDate,
                                    endDate: trip.endDate,
                                    status: trip.status,
                                    coverImageUrl: trip.coverImageUrl,
                                    participantIDs: trip.participantIDs,
                                    totalPlaces: trip.totalPlaces,
                                    createdAt: trip.createdAt,
                                    createdBy: trip.createdBy
                                )
                            }

                            let encoder = JSONEncoder()
                            encoder.dateEncodingStrategy = .secondsSince1970
                            let data = try encoder.encode(dtos)

                            if let jsonString = String(data: data, encoding: .utf8) {
                                replyData["tripsJSON"] = jsonString
                                replyHandler(replyData)
                            } else {
                                replyHandler(replyData)
                            }
                        } catch {
                            print(
                                "[IOSWatchSessionManager] Fetch failed for reply: \(error)"
                            )
                            replyHandler(replyData)
                        }
                    }
                } else {
                    replyData["tripsJSON"] = "[]"
                    replyHandler(replyData)
                }

            case "fetchTripDetails":
                print("[IOSWatchSessionManager] Watch requested fetchTripDetails.")
                guard let tripId = message["tripId"] as? String,
                      let uid = Auth.auth().currentUser?.uid else {
                    replyHandler(["status": "error", "message": "Missing tripId or user not logged in"])
                    return
                }

                Task { @MainActor in
                    do {
                        let firestore = FirestoreRepository()
                        let dayPlans = try await firestore.fetchDayPlans(forTripID: tripId, userID: uid)

                        let dtos = dayPlans.map { plan in
                            DayPlanDTO(
                                id: plan.id,
                                dayNumber: plan.dayNumber,
                                date: plan.date,
                                destinations: plan.destinations
                            )
                        }

                        let encoder = JSONEncoder()
                        encoder.dateEncodingStrategy = .secondsSince1970
                        let data = try encoder.encode(dtos)

                        if let jsonString = String(data: data, encoding: .utf8) {
                            replyHandler(["status": "success", "dayPlansJSON": jsonString])
                        } else {
                            replyHandler(["status": "error", "message": "Failed to encode day plans"])
                        }
                    } catch {
                        print("[IOSWatchSessionManager] Failed to fetch day plans: \(error)")
                        replyHandler(["status": "error", "message": error.localizedDescription])
                    }
                }

            default:
                replyHandler(["status": "unknown_request"])
            }
        } else {
            replyHandler(["status": "unknown_request"])
        }
    }
}
