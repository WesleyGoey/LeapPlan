//
//  FSQResponse.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

class FourSquareService: FourSquareServiceProtocol {
    
    // ⚠️ MASUKKAN KUNCI API BARUMU DI SINI (Pastikan tidak ada spasi di awal/akhir)
    private let apiKey = "RAD1ODGEX4S2UKH55GHDYYEMLWQMVBWPMLEEADELCIKAINWY"
    
    // URL Host Baru sesuai Migrasi Foursquare
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
        
        // 1. Menggunakan format Bearer yang benar
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // 2. Menggunakan versi tanggal yang sah sesuai dokumen baru Foursquare
        request.addValue("2025-06-17", forHTTPHeaderField: "X-Places-Api-Version")
        
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
