//
//  TripRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import FirebaseFirestore

class TripRepository: TripRepositoryProtocol {
    private let db = Firestore.firestore()
    
    // MARK: - Trip Operations
    func fetchTrips(forUserID userID: String) async throws -> [Trip] {
        let snapshot = try await db.collection("Users").document(userID).collection("Trips")
            .order(by: "startDate", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Trip.self) }
    }
    
    func createTrip(_ trip: Trip, forUserID userID: String) async throws {
        let collectionRef = db.collection("Users").document(userID).collection("Trips")
        let docRef = trip.id != nil ? collectionRef.document(trip.id!) : collectionRef.document()
        var newTrip = trip
        newTrip.id = docRef.documentID
        try docRef.setData(from: newTrip)
    }
    
    func updateTrip(_ trip: Trip, forUserID userID: String) async throws {
        guard let tripID = trip.id else { return }
        let docRef = db.collection("Users").document(userID).collection("Trips").document(tripID)
        try docRef.setData(from: trip, merge: true)
    }
    
    func deleteTrip(tripID: String, forUserID userID: String) async throws {
        try await db.collection("Users").document(userID).collection("Trips").document(tripID).delete()
    }
    
    // MARK: - DayPlan Operations
    func fetchDayPlans(forTripID tripID: String, userID: String) async throws -> [DayPlan] {
        let snapshot = try await db.collection("Users").document(userID)
            .collection("Trips").document(tripID)
            .collection("DayPlans")
            .order(by: "dayNumber")
            .getDocuments()
            
        return snapshot.documents.compactMap { try? $0.data(as: DayPlan.self) }
    }
    
    func saveDayPlan(_ dayPlan: DayPlan, forTripID tripID: String, userID: String) async throws {
        let collectionRef = db.collection("Users").document(userID)
            .collection("Trips").document(tripID)
            .collection("DayPlans")
            
        let docRef = dayPlan.id != nil ? collectionRef.document(dayPlan.id!) : collectionRef.document()
        var newPlan = dayPlan
        newPlan.id = docRef.documentID
        try docRef.setData(from: newPlan)
    }
    
    // MARK: - BATCH WRITE (PENTING UNTUK GENERATE TRIP)
    func saveGeneratedTripWithDayPlans(trip: Trip, dayPlans: [DayPlan], userID: String) async throws {
        let batch = db.batch()
        
        let tripDocRef = db.collection("Users").document(userID).collection("Trips").document()
        var newTrip = trip
        newTrip.id = tripDocRef.documentID
        
        try batch.setData(from: newTrip, forDocument: tripDocRef)
        
        let dayPlansCollectionRef = tripDocRef.collection("DayPlans")
        for plan in dayPlans {
            let dayPlanDocRef = dayPlansCollectionRef.document()
            var newPlan = plan
            newPlan.id = dayPlanDocRef.documentID
            try batch.setData(from: newPlan, forDocument: dayPlanDocRef)
        }
        
        try await batch.commit()
    }
}
