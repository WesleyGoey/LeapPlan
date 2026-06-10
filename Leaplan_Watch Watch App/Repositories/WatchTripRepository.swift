//
//  WatchTripRepository.swift
//  Leaplan_Watch Watch App
//
//  Created by Wesley Goey on 10/06/26.
//

import Foundation
import WatchConnectivity

// MARK: - Day Plan Dto
struct DayPlanDTO: Identifiable, Codable {
    var id: String?
    var dayNumber: Int
    var date: Date
    var destinations: [TripDestination]
}

// MARK: - Watch Trip Repository
class WatchTripRepository: WatchTripRepositoryProtocol {
    // MARK: - Fetch Trips
    func fetchTrips() async throws -> [Trip] {
        return try await withCheckedThrowingContinuation { continuation in
            guard WCSession.default.activationState == .activated,
                WCSession.default.isReachable
            else {
                continuation.resume(
                    throwing: NSError(
                        domain: "WatchTripRepository",
                        code: 1,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "iPhone is not reachable."
                        ]
                    )
                )
                return
            }

            WCSession.default.sendMessage(["request": "fetchLatestData"]) {
                reply in
                if let tripsJSON = reply["tripsJSON"] as? String,
                    let data = tripsJSON.data(using: .utf8)
                {
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

    // MARK: - Fetch Trip Details
    func fetchTripDetails(tripId: String) async throws -> [DayPlan] {
        return try await withCheckedThrowingContinuation { continuation in
            guard WCSession.default.activationState == .activated,
                WCSession.default.isReachable
            else {
                continuation.resume(
                    throwing: NSError(
                        domain: "WatchTripRepository",
                        code: 1,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "iPhone is not reachable."
                        ]
                    )
                )
                return
            }

            let message = ["request": "fetchTripDetails", "tripId": tripId]
            WCSession.default.sendMessage(message) { reply in
                if let status = reply["status"] as? String, status == "success",
                    let dayPlansJSON = reply["dayPlansJSON"] as? String,
                    let data = dayPlansJSON.data(using: .utf8)
                {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970
                        let dtos = try decoder.decode(
                            [DayPlanDTO].self,
                            from: data
                        )
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
                    let errorMessage =
                        reply["message"] as? String
                        ?? "Failed to fetch trip details"
                    continuation.resume(
                        throwing: NSError(
                            domain: "WatchTripRepository",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: errorMessage]
                        )
                    )
                }
            } errorHandler: { error in
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Generate Random Place
    func generateRandomPlace(
        tripId: String,
        dayPlanId: String,
        tripLocationName: String
    ) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            guard WCSession.default.activationState == .activated,
                WCSession.default.isReachable
            else {
                continuation.resume(
                    throwing: NSError(
                        domain: "WatchTripRepository",
                        code: 1,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "iPhone is not reachable."
                        ]
                    )
                )
                return
            }

            let message = [
                "request": "generateRandomPlace", "tripId": tripId,
                "dayPlanId": dayPlanId, "tripLocationName": tripLocationName,
            ]
            WCSession.default.sendMessage(message) { reply in
                if let status = reply["status"] as? String, status == "success"
                {
                    continuation.resume(returning: true)
                } else {
                    let errorMessage =
                        reply["message"] as? String
                        ?? "Failed to generate place"
                    continuation.resume(
                        throwing: NSError(
                            domain: "WatchTripRepository",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: errorMessage]
                        )
                    )
                }
            } errorHandler: { error in
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Save Reordered Destinations
    func saveReorderedDestinations(tripId: String, dayPlan: DayPlan)
        async throws -> Bool
    {
        return try await withCheckedThrowingContinuation { continuation in
            guard WCSession.default.activationState == .activated,
                WCSession.default.isReachable
            else {
                continuation.resume(
                    throwing: NSError(
                        domain: "WatchTripRepository",
                        code: 1,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "iPhone is not reachable."
                        ]
                    )
                )
                return
            }

            let dto = DayPlanDTO(
                id: dayPlan.id,
                dayNumber: dayPlan.dayNumber,
                date: dayPlan.date,
                destinations: dayPlan.destinations
            )
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            guard let data = try? encoder.encode(dto),
                let jsonString = String(data: data, encoding: .utf8)
            else {
                continuation.resume(
                    throwing: NSError(
                        domain: "WatchTripRepository",
                        code: 3,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Failed to encode dayPlan"
                        ]
                    )
                )
                return
            }

            let message = [
                "request": "saveReorderedDestinations", "tripId": tripId,
                "dayPlanJSON": jsonString,
            ]
            WCSession.default.sendMessage(message) { reply in
                if let status = reply["status"] as? String, status == "success"
                {
                    continuation.resume(returning: true)
                } else {
                    let errorMessage =
                        reply["message"] as? String
                        ?? "Failed to save reordered destinations"
                    continuation.resume(
                        throwing: NSError(
                            domain: "WatchTripRepository",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: errorMessage]
                        )
                    )
                }
            } errorHandler: { error in
                continuation.resume(throwing: error)
            }
        }
    }
}
