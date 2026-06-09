//
//  WatchSessionManager.swift
//  Leaplan_Watch Watch App
//

import Combine
import Foundation
import WatchConnectivity

// MARK: - WatchSessionManager

@MainActor
final class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {

    // MARK: - Published State

    @Published var isLoggedIn: Bool = false
    @Published var syncedTrips: [Trip] = []

    // MARK: - Initialization

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Public API

    /// Explicitly pulls the current authentication status and live trip data from the iPhone.
    func sendSyncRequest() {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isReachable else {
            print("[WatchSessionManager] WCSession not reachable for sendMessage.")
            return
        }

        let requestMessage: [String: Any] = ["request": "fetchLatestData"]
        WCSession.default.sendMessage(requestMessage, replyHandler: { [weak self] reply in
            self?.handlePayload(reply)
        }, errorHandler: { error in
            print("[WatchSessionManager] Sync request failed: \(error.localizedDescription)")
        })
    }

    // MARK: - WCSessionDelegate (MainActor isolated via Task)

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("[WatchSessionManager] Activation failed: \(error.localizedDescription)")
            return
        }
        
        // Handle any context received while the app was closed.
        let context = session.receivedApplicationContext
        if !context.isEmpty {
            Task { @MainActor in
                self.handlePayload(context)
            }
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        Task { @MainActor in
            self.handlePayload(applicationContext)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any]
    ) {
        Task { @MainActor in
            self.handlePayload(message)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        Task { @MainActor in
            self.handlePayload(message)
        }
        replyHandler(["status": "received"])
    }

    // MARK: - Payload Handler

    private func handlePayload(_ payload: [String: Any]) {
        if let loginStatus = payload["isLoggedIn"] as? Bool {
            self.isLoggedIn = loginStatus
            if !loginStatus {
                self.syncedTrips = [] // Clear trips on logout
            }
        }

        if let tripsJSONString = payload["tripsJSON"] as? String,
           let data = tripsJSONString.data(using: .utf8) {
            decodeTrips(from: data)
        } else if let tripsData = payload["tripsData"] as? Data {
            decodeTrips(from: tripsData)
        } else if let tripsBase64 = payload["tripsData"] as? String,
                  let data = Data(base64Encoded: tripsBase64) {
            decodeTrips(from: data)
        }
    }

    private func decodeTrips(from data: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let decodedTrips = try decoder.decode([Trip].self, from: data)
            self.syncedTrips = decodedTrips
        } catch {
            print("[WatchSessionManager] Failed to decode trips JSON: \(error)")
        }
    }
}
