//
//  FourSquareService.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

class FourSquareService: FourSquareServiceProtocol {
    
    // API KEY MILIKMU
    private let apiKey = "RAD1ODGEX4S2UKH55GHDYYEMLWQMVBWPMLEEADELCIKAINWY"
    
    // BASE URL UTAMA (Root dari API Baru Foursquare)
    private let baseURL = "https://places-api.foursquare.com"
    
    // HELPER: Mengatur keamanan untuk SEMUA fungsi sekaligus
    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Wajib menggunakan Bearer untuk API baru
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Wajib menggunakan Version Date untuk API baru
        request.addValue("2025-06-17", forHTTPHeaderField: "X-Places-Api-Version")
        
        request.timeoutInterval = 10.0
        return request
    }
    
    // HELPER: Menangani error agar log di Xcode jelas
    private func handleResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if httpResponse.statusCode != 200 {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
            print("Foursquare Error [\(httpResponse.statusCode)]: \(errorMsg)")
            throw NSError(domain: "FoursquareAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error \(httpResponse.statusCode): Foursquare menolak request."])
        }
    }

    // MARK: - 1. Fetch Trending Places
    func fetchTrendingPlaces(city: String) async throws -> [FSQPlace] {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/places/search?near=\(encodedCity)&sort=RELEVANCE&limit=10") else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        
        let fsqResponse = try JSONDecoder().decode(FSQSearchResponse.self, from: data)
        return fsqResponse.results
    }
    
    // MARK: - 2. Search Places by Coordinates (UNTUK FITUR SEARCH KAMU DI PETA)
    func searchPlaces(query: String, latitude: Double, longitude: Double) async throws -> [FSQPlace] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/places/search?query=\(encodedQuery)&ll=\(latitude),\(longitude)&limit=15") else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        
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
                
                // Gabungkan primary (Misal: "Surabaya") dan secondary (Misal: "East Java")
                let cityName = result.text.primary
                let detail = result.text.secondary ?? ""
                let fullName = detail.isEmpty ? cityName : "\(cityName), \(detail)"
                
                return FSQPlace(
                    fsq_place_id: result.text.primary,
                    name: fullName,
                    distance: 0,
                    latitude: geoItem.center?.latitude ?? 0.0,
                    longitude: geoItem.center?.longitude ?? 0.0
                )
            }
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        
        let fsqResponse = try JSONDecoder().decode(FSQAutocompleteResponse.self, from: data)
        return fsqResponse.results.compactMap { result in
            guard let geoItem = result.geo else { return nil }
            return FSQPlace(
                fsq_place_id: result.text.primary,
                name: result.text.full,
                distance: 0,
                latitude: geoItem.center?.latitude ?? 0.0,
                longitude: geoItem.center?.longitude ?? 0.0,
                location: nil,
                rating: nil,
                stats: nil
            )
        }
    }
    
    // MARK: - 4. Fetch Places (TAMBAHAN UNTUK TEMAN KAMU)
    func fetchPlaces(near city: String, categoryID: String, limit: Int) async throws -> [FSQPlace] {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/places/search?near=\(encodedCity)&categories=\(categoryID)&limit=\(limit)&sort=POPULARITY") else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        
        let fsqResponse = try JSONDecoder().decode(FSQSearchResponse.self, from: data)
        return fsqResponse.results
    }
}

// MARK: - Helper Codable Structs
private struct FSQSearchResponse: Codable { let results: [FSQPlace] }
private struct FSQAutocompleteResponse: Codable { let results: [AutocompleteResult] }
private struct AutocompleteResult: Codable { let text: TextWrapper; let geo: GeoWrapper? }
private struct TextWrapper: Codable {
    let primary: String
    let secondary: String?
}
private struct GeoWrapper: Codable { let center: CenterCoordinates? }
private struct CenterCoordinates: Codable { let latitude: Double; let longitude: Double }
