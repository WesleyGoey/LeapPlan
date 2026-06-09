//
//  WatchTripRepository.swift
//  Leaplan_Watch Watch App
//

import Foundation
import WatchConnectivity

struct DayPlanDTO: Identifiable, Codable {
    var id: String?
    var dayNumber: Int
    var date: Date
    var destinations: [TripDestination]
}

class WatchTripRepository: WatchTripRepositoryProtocol {
    
    // We keep a reference to WatchSessionManager to check if it's reachable or we just use WCSession directly.
    // For simplicity and direct use of WCSession in async context:
    
    func fetchTrips() async throws -> [Trip] {
        // We can just rely on the existing published syncedTrips in WatchSessionManager, 
        // or trigger a fetch. Let's do a direct fetch for consistency with protocol.
        return try await withCheckedThrowingContinuation { continuation in
            guard WCSession.default.activationState == .activated,
                  WCSession.default.isReachable else {
                continuation.resume(throwing: NSError(domain: "WatchTripRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "iPhone is not reachable."]))
                return
            }
            
            WCSession.default.sendMessage(["request": "fetchLatestData"]) { reply in
                if let tripsJSON = reply["tripsJSON"] as? String, let data = tripsJSON.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970
                        let trips = try decoder.decode([Trip].self, from: data)
                        continuation.resume(returning: trips)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    continuation.resume(returning: [])
                }
            } errorHandler: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    func fetchTripDetails(tripId: String) async throws -> [DayPlan] {
        return try await withCheckedThrowingContinuation { continuation in
            guard WCSession.default.activationState == .activated,
                  WCSession.default.isReachable else {
                continuation.resume(throwing: NSError(domain: "WatchTripRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "iPhone is not reachable."]))
                return
            }
            
            let message = ["request": "fetchTripDetails", "tripId": tripId]
            WCSession.default.sendMessage(message) { reply in
                if let status = reply["status"] as? String, status == "success",
                   let dayPlansJSON = reply["dayPlansJSON"] as? String,
                   let data = dayPlansJSON.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970
                        let dtos = try decoder.decode([DayPlanDTO].self, from: data)
                        let dayPlans = dtos.map { dto in
                            DayPlan(
                                id: dto.id,
                                dayNumber: dto.dayNumber,
                                date: dto.date,
                                destinations: dto.destinations
                            )
                        }
                        continuation.resume(returning: dayPlans)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    let errorMessage = reply["message"] as? String ?? "Failed to fetch trip details"
                    continuation.resume(throwing: NSError(domain: "WatchTripRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            } errorHandler: { error in
                continuation.resume(throwing: error)
            }
        }
    }
}
