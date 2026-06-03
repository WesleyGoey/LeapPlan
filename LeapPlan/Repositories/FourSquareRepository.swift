//
//  FourSquareRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation

class FourSquareRepository: FourSquareRepositoryProtocol {
    private let apiKey = "RAD1ODGEX4S2UKH55GHDYYEMLWQMVBWPMLEEADELCIKAINWY"
    private let baseURL = "https://places-api.foursquare.com"

    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(
            "Bearer \(apiKey)",
            forHTTPHeaderField: "Authorization"
        )
        request.addValue(
            "2025-06-17",
            forHTTPHeaderField: "X-Places-Api-Version"
        )
        request.timeoutInterval = 10.0
        return request
    }

    private func handleResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if httpResponse.statusCode != 200 {
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
                string:
                    "\(baseURL)/places/search?query=\(encodedQuery)&ll=\(latitude),\(longitude)&limit=15"
            )
        else { throw URLError(.badURL) }
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        return try JSONDecoder().decode(FSQResponse.self, from: data).results
    }

    // Fungsi baru untuk mencari tempat spesifik di kota tertentu
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
                string:
                    "\(baseURL)/places/search?near=\(encodedCity)&query=\(encodedQuery)&limit=\(limit)"
            )
        else { throw URLError(.badURL) }

        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)

        // Menggunakan struct yang sudah ada di file Anda
        struct FSQSearchResponse: Codable { let results: [FSQPlace] }
        return try JSONDecoder().decode(FSQSearchResponse.self, from: data)
            .results
    }

    func fetchPlaces(near city: String, categoryID: String, limit: Int)
        async throws -> [FSQPlace]
    {
        guard
            let encodedCity = city.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ),
            let url = URL(
                string:
                    "\(baseURL)/places/search?near=\(encodedCity)&categories=\(categoryID)&limit=\(limit)&sort=POPULARITY"
            )
        else { throw URLError(.badURL) }
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        return try JSONDecoder().decode(FSQResponse.self, from: data).results
    }

    func autocompleteLocation(query: String) async throws -> [FSQPlace] {
        guard
            let encodedQuery = query.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ),
            let url = URL(
                string:
                    "\(baseURL)/autocomplete?query=\(encodedQuery)&types=geo&limit=5"
            )
        else { throw URLError(.badURL) }
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)

        let fsqResponse = try JSONDecoder().decode(
            FSQAutocompleteResponse.self,
            from: data
        )
        return fsqResponse.results.compactMap { result in
            guard let geoItem = result.geo else { return nil }
            let cityName = result.text.primary
            let detail = result.text.secondary ?? ""
            let fullName = detail.isEmpty ? cityName : "\(cityName), \(detail)"
            return FSQPlace(
                fsq_place_id: result.text.primary,
                name: fullName,
                distance: 0,
                latitude: geoItem.center?.latitude ?? 0.0,
                longitude: geoItem.center?.longitude ?? 0.0,
                location: nil,
                rating: nil,
                stats: nil
            )
        }
    }

    // MARK: - API UNTUK FOTO FOURSQUARE
    func fetchPlacePhotos(id: String) async throws -> String? {
        guard
            let url = URL(
                string: "\(baseURL)/places/\(id)/photos?limit=1&sort=POPULAR"
            )
        else { return nil }
        let request = createRequest(url: url)
        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else { return nil }

            struct FSQPhotoResponse: Codable {
                let prefix: String
                let suffix: String
            }
            let photos = try JSONDecoder().decode(
                [FSQPhotoResponse].self,
                from: data
            )

            // Foursquare menyajikan prefix & suffix. Kita satukan menjadi ukuran 500x500
            if let first = photos.first {
                return "\(first.prefix)500x500\(first.suffix)"
            }
            return nil
        } catch { return nil }
    }
}

// MARK: - Helper Codable Structs
private struct FSQSearchResponse: Codable { let results: [FSQPlace] }
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
