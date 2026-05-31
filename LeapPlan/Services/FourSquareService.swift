//
//  FSQResponse.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

class FourSquareService: FourSquareServiceProtocol {
    // Tempel (Paste) kunci rahasia baru kamu yang diawali huruf RAD1... di sini
    private let apiKey = "RAD1ODGEX4S2UKH55GHDYYEMLWQMVBWPMLEADELCIKAINWY"
    
    // Pastikan base URL kamu sudah mengarah ke host migrasi baru yang kita bahas tadi
    private let baseURL = "https://places-api.foursquare.com/places/search"
    
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
        
        // Header Otentikasi Bearer (Sudah benar)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // REVISI DI SINI: Gunakan versi stabil global Foursquare v3 API
        request.addValue("2023-10-10", forHTTPHeaderField: "X-Places-Api-Version")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                let decoded = try JSONDecoder().decode(FSQResponse.self, from: data)
                return decoded.results
            } else {
                let errorMessage = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                let message = errorMessage?["message"] as? String ?? "Unknown Error"
                throw NSError(domain: "FoursquareAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error \(httpResponse.statusCode): \(message)"])
            }
        }
        throw URLError(.badServerResponse)
    }
}
