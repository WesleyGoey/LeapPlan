//
//  FourSquareService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

class FourSquareService: FourSquareServiceProtocol {
    
    // API KEY MILIKMU (TIDAK DIUBAH)
    private let apiKey = "RAD1ODGEX4S2UKH55GHDYYEMLWQMVBWPMLEEADELCIKAINWY"
    
    // FIX: Base URL yang benar untuk Foursquare v3 adalah ini, BUKAN diakhiri dengan /places/search
    private let baseURL = "https://api.foursquare.com/v3"
    
    // Helper untuk membuat URLRequest dengan Header Otentikasi Foursquare
    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10.0
        return request
    }
    
    // MARK: - 1. Fetch Trending Places
    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace] {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/places/search?near=\(encodedCity)&sort=RELEVANCE&limit=10") else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let fsqResponse = try JSONDecoder().decode(FSQSearchResponse.self, from: data)
        return fsqResponse.results
    }
    
    // MARK: - 2. Search Places by Coordinates
    func searchPlaces(query: String, latitude: Double, longitude: Double) async throws -> [FSQPlace] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/places/search?query=\(encodedQuery)&ll=\(latitude),\(longitude)&limit=15") else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let fsqResponse = try JSONDecoder().decode(FSQSearchResponse.self, from: data)
        return fsqResponse.results
    }
    
    // MARK: - 3. Autocomplete Location
    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/autocomplete?query=\(encodedQuery)&types=geo&limit=5") else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let fsqResponse = try JSONDecoder().decode(FSQAutocompleteResponse.self, from: data)
        return fsqResponse.results.compactMap { result in
            guard let geoItem = result.geo else { return nil }
            return FSQPlace(
                fsq_place_id: result.text.primary,
                name: result.text.full,
                distance: 0,
                latitude: geoItem.center?.latitude ?? 0.0,
                longitude: geoItem.center?.longitude ?? 0.0
            )
        }
    }
    
    // MARK: - 4. Fetch Places
    func fetchPlaces(near city: String, categoryID: String, limit: Int) async throws -> [FSQPlace] {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/places/search?near=\(encodedCity)&categories=\(categoryID)&limit=\(limit)&sort=POPULARITY") else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let fsqResponse = try JSONDecoder().decode(FSQSearchResponse.self, from: data)
        return fsqResponse.results
    }
}

// MARK: - Helper Codable Structs
private struct FSQSearchResponse: Codable { let results: [FSQPlace] }
private struct FSQAutocompleteResponse: Codable { let results: [AutocompleteResult] }
private struct AutocompleteResult: Codable { let text: TextWrapper; let geo: GeoWrapper? }
private struct TextWrapper: Codable { let primary: String; let full: String }
private struct GeoWrapper: Codable { let center: CenterCoordinates? }
private struct CenterCoordinates: Codable { let latitude: Double; let longitude: Double }
