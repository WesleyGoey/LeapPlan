//
//  FSQResponse.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

// MARK: - DTO Model (Sebaiknya letakkan di folder Models dengan nama FSQPlace.swift)
struct FSQResponse: Codable { let results: [FSQPlace] }
struct FSQPlace: Identifiable, Codable {
    let fsq_id: String
    let name: String
    let distance: Int?
    var id: String { fsq_id }
}

class FourSquareService: FourSquareServiceProtocol {
    private let apiKey = "YOUR_FOURSQUARE_API_KEY"
    private let baseURL = "https://api.foursquare.com/v3/places/search"
    
    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace] {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "near", value: city),
            URLQueryItem(name: "sort", value: "RATING"),
            URLQueryItem(name: "limit", value: "10")
        ]
        return try await performRequest(url: components.url!)
    }
    
    func searchPlaces(query: String, latitude: Double, longitude: Double) async throws -> [FSQPlace] {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "ll", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "limit", value: "15")
        ]
        return try await performRequest(url: components.url!)
    }
    
    private func performRequest(url: URL) async throws -> [FSQPlace] {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(FSQResponse.self, from: data)
        return decoded.results
    }
}