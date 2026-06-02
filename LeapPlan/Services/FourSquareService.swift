//
//  FourSquareService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

class FourSquareService: FourSquareServiceProtocol {
    
    // Ganti dengan API Key Foursquare milikmu sendiri dari Developer Console Foursquare
    private let apiKey = "RAD1ODGEX4S2UKH55GHDYYEMLWQMVBWPMLEEADELCIKAINWY"
    private let baseURL = "https://places-api.foursquare.com/places/search"
    
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
        // Menggunakan Place Search dengan sorting popularity/relevance sebagai alternatif trending
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
    
    // MARK: - 3. BARU: Autocomplete Location (Mencari Kota/Tujuan saat user mengetik)
    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              // Kita kunci types=geo agar Foursquare fokus mengembalikan nama daerah/kota, bukan toko spesifik
              let url = URL(string: "\(baseURL)/autocomplete?query=\(encodedQuery)&types=geo&limit=5") else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Foursquare Autocomplete mengembalikan struktur bungkusan sedikit berbeda (results berisi data geo)
        let fsqResponse = try JSONDecoder().decode(FSQAutocompleteResponse.self, from: data)
        
        // Map hasil autocomplete menjadi FSQPlace agar seragam dengan fungsi lainnya
        return fsqResponse.results.compactMap { result in
            guard let geoItem = result.geo else { return nil }
            return FSQPlace(
                fsq_place_id: result.text.primary, // Menggunakan teks nama kota sebagai ID unik sementara
                name: result.text.full,            // Nama lengkap kota (Contoh: "Tokyo, Japan")
                distance: 0,
                latitude: geoItem.center?.latitude ?? 0.0,
                longitude: geoItem.center?.longitude ?? 0.0
            )
        }
    }
    
    // MARK: - 4. BARU: Fetch Places (Mencari Restoran/Wisata Nyata di Kota Tersebut)
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

// MARK: - Helper Codable Structs untuk response JSON Foursquare API

private struct FSQSearchResponse: Codable {
    let results: [FSQPlace]
}

private struct FSQAutocompleteResponse: Codable {
    let results: [AutocompleteResult]
}

private struct AutocompleteResult: Codable {
    let text: TextWrapper
    let geo: GeoWrapper?
}

private struct TextWrapper: Codable {
    let primary: String
    let full: String
}

private struct GeoWrapper: Codable {
    let center: CenterCoordinates?
}

private struct CenterCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}
