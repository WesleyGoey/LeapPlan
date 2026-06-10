//
//  FourSquareRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation

class FourSquareRepository: FourSquareRepositoryProtocol {
    private let apiKey = "412LZ03GGTRUXOOXRUJNK30LQ1J2NUL2VMYK0JJ30204STMD"
    private let baseURL = "https://places-api.foursquare.com/v3" // 🔥 PENTING: Tambahin /v3

    // 🔥 PENTING: Ini daftar data yang kita paksa minta dari Foursquare
    private let requiredFields = "fsq_id,name,location,rating,stats,photos"

    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(
            "\(apiKey)", // 🔥 PENTING: Foursquare V3 nggak pakai tulisan "Bearer ", cuma key doang
            forHTTPHeaderField: "Authorization"
        )
        // Versi API nggak butuh dikirim di header kalau udah pakai /v3 di baseURL
        request.timeoutInterval = 10.0
        return request
    }

    private func handleResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if httpResponse.statusCode != 200 {
            // Trik debugging: Print isi surat penolakan Foursquare
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Foursquare Error"
            print("🚨 FOURSQUARE ERROR \(httpResponse.statusCode): \(errorMsg)")
            
            throw NSError(
                domain: "FoursquareAPI",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Error Foursquare"]
            )
        }
    }

    func searchPlaces(query: String, latitude: Double, longitude: Double)
        async throws -> [FSQPlace]
    {
        guard
            let encodedQuery = query.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ),
            let url = URL(
                string: "\(baseURL)/places/search?query=\(encodedQuery)&ll=\(latitude),\(longitude)&limit=15&fields=\(requiredFields)"
            )
        else { throw URLError(.badURL) }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        
        let rawPlaces = try JSONDecoder().decode(FSQResponse.self, from: data).results
        return mapPhotos(for: rawPlaces)
    }

    func searchPlacesByCity(near city: String, query: String, limit: Int)
        async throws -> [FSQPlace]
    {
        guard
            let encodedCity = city.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ),
            let encodedQuery = query.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ),
            let url = URL(
                string: "\(baseURL)/places/search?near=\(encodedCity)&query=\(encodedQuery)&limit=\(limit)&fields=\(requiredFields)"
            )
        else { throw URLError(.badURL) }

        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)

        struct FSQSearchResponse: Codable { let results: [FSQPlace] }
        let rawPlaces = try JSONDecoder().decode(FSQSearchResponse.self, from: data).results
        return mapPhotos(for: rawPlaces)
    }

    func fetchPlaces(near city: String, categoryID: String, limit: Int)
        async throws -> [FSQPlace]
    {
        guard
            let encodedCity = city.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ),
            let url = URL(
                string: "\(baseURL)/places/search?near=\(encodedCity)&categories=\(categoryID)&limit=\(limit)&sort=POPULARITY&fields=\(requiredFields)"
            )
        else { throw URLError(.badURL) }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        
        let rawPlaces = try JSONDecoder().decode(FSQResponse.self, from: data).results
        return mapPhotos(for: rawPlaces) // Panggil fungsi helper di bawah
    }

    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
            guard
                let encodedQuery = query.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                ),
                let url = URL(
                    string: "\(baseURL)/autocomplete?query=\(encodedQuery)&types=geo&limit=5"
                )
            else { throw URLError(.badURL) }
            let request = createRequest(url: url)
            let (data, response) = try await URLSession.shared.data(for: request)
            try handleResponse(data: data, response: response)

            let fsqResponse = try JSONDecoder().decode(
                FSQAutocompleteResponse.self,
                from: data
            )
            
            // 🔥 FIX: Kasih tau Swift secara eksplisit kalau kita balikin FSQPlace?
            return fsqResponse.results.compactMap { result -> FSQPlace? in
                guard let geoItem = result.geo else { return nil }
                let cityName = result.text.primary
                let detail = result.text.secondary ?? ""
                let fullName = detail.isEmpty ? cityName : "\(cityName), \(detail)"
                
                // 🔥 FIX: Bungkus latitude & longitude ke dalem Geocodes sesuai model baru
                let lat = geoItem.center?.latitude ?? 0.0
                let lng = geoItem.center?.longitude ?? 0.0
                let geocodesData = FSQGeocodes(main: FSQMainGeocode(latitude: lat, longitude: lng))
                
                return FSQPlace(
                    fsq_place_id: result.text.primary,
                    name: fullName,
                    distance: 0,
                    location: nil,
                    rating: nil,
                    stats: nil,
                    photos: nil, // Autocomplete nggak dapet foto
                    geocodes: geocodesData, // Pake geocodes yang baru dibikin
                    imageURL: nil
                )
            }
        }

    // Fungsi ini udah nggak dipake lagi karena foto udah dapet dari search awal
    func fetchPlacePhotos(id: String) async throws -> String? {
        return nil
    }
    
    // MARK: - HELPER FUNGSI BUAT JAHIT FOTO
    // Fungsi ini otomatis ngejahit prefix + suffix dari data yang didapat
    private func mapPhotos(for places: [FSQPlace]) -> [FSQPlace] {
        var updatedPlaces = places
        for i in 0..<updatedPlaces.count {
            if let photo = updatedPlaces[i].photos?.first {
                updatedPlaces[i].imageURL = "\(photo.prefix)original\(photo.suffix)"
            }
        }
        return updatedPlaces
    }
}

// MARK: - Helper Codable Structs
private struct FSQAutocompleteResponse: Codable {
    let results: [AutocompleteResult]
}
private struct AutocompleteResult: Codable {
    let text: TextWrapper
    let geo: GeoWrapper?
}
private struct TextWrapper: Codable {
    let primary: String
    let secondary: String?
}
private struct GeoWrapper: Codable { let center: CenterCoordinates? }
private struct CenterCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}
