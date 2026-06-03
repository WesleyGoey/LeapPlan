//
//  FourSquareService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

class FourSquareService: FourSquareServiceProtocol {
    private let repo: FourSquareRepositoryProtocol
    
    init(repo: FourSquareRepositoryProtocol = FourSquareRepository()) {
        self.repo = repo
    }
    
    // MARK: - ASYNC TASKGROUP UNTUK MENGUNDUH URL GAMBAR SERENTAK
    private func attachPhotos(to places: [FSQPlace]) async -> [FSQPlace] {
        return await withTaskGroup(of: (Int, String?).self) { group in
            for (index, place) in places.enumerated() {
                group.addTask {
                    let url = try? await self.repo.fetchPlacePhotos(id: place.fsq_place_id)
                    return (index, url)
                }
            }
            var updatedPlaces = places
            for await (index, url) in group {
                updatedPlaces[index].imageURL = url
            }
            return updatedPlaces
        }
    }
    
    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace] {
        let places = try await repo.fetchPlaces(near: city, categoryID: "16000", limit: 10)
        return await attachPhotos(to: places) // Tempel foto
    }
    
    func searchPlaces(query: String, latitude: Double, longitude: Double) async throws -> [FSQPlace] {
        let places = try await repo.searchPlaces(query: query, latitude: latitude, longitude: longitude)
        return await attachPhotos(to: places) // Tempel foto
    }
    
    func fetchPlaces(near city: String, categoryID: String, limit: Int) async throws -> [FSQPlace] {
        let places = try await repo.fetchPlaces(near: city, categoryID: categoryID, limit: limit)
        return await attachPhotos(to: places) // Tempel foto
    }
    
    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        return try await repo.autocompleteLocation(query: query)
    }
}
