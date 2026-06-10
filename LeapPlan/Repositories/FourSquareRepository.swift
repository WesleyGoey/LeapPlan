//
//  FourSquareRepository.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import Foundation

class FourSquareRepository: FourSquareRepositoryProtocol {
    private let apiKey = "3DK5KUE00UX30UQXJREU1Z0FJVSRJDU1R2QYMFOS4DCNSR4N"
    private let baseURL = "https://places-api.foursquare.com"

    // MARK: - Create Request
    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(
            "\(apiKey)", // 🔥 PENTING: Foursquare V3 nggak pakai tulisan "Bearer ", cuma key doang
            forHTTPHeaderField: "Authorization"
        )
        request.timeoutInterval = 10.0
        return request
    }

    // MARK: - Handle Response
    private func handleResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if httpResponse.statusCode != 200 {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Foursquare Error"
            print("🚨 FOURSQUARE ERROR \(httpResponse.statusCode): \(errorMsg)")
            
            throw NSError(
                domain: "FoursquareAPI",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Error Foursquare"]
            )
        }
    }

    // MARK: - Search Places
    func searchPlaces(query: String, latitude: Double, longitude: Double)
        async throws -> [FSQPlace]
    {
        guard
            let encodedQuery = query.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ),
            let url = URL(
                string:
                    "\(baseURL)/places/search?query=\(encodedQuery)&ll=\(latitude),\(longitude)&limit=15&fields=fsq_place_id,name,latitude,longitude,location"
            )
        else { throw URLError(.badURL) }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        
        let rawPlaces = try JSONDecoder().decode(FSQResponse.self, from: data).results
        return rawPlaces
    }

    // MARK: - Search Places By City
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
                    "\(baseURL)/places/search?near=\(encodedCity)&query=\(encodedQuery)&limit=\(limit)&fields=fsq_place_id,name,latitude,longitude,location"
            )
        else { throw URLError(.badURL) }

        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)

        struct FSQSearchResponse: Codable { let results: [FSQPlace] }
        let rawPlaces = try JSONDecoder().decode(FSQSearchResponse.self, from: data).results
        return rawPlaces
    }

    // MARK: - Fetch Places
    func fetchPlaces(near city: String, categoryID: String, limit: Int)
        async throws -> [FSQPlace]
    {
        guard
            let encodedCity = city.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ),
            let url = URL(
                string:
                    "\(baseURL)/places/search?near=\(encodedCity)&categories=\(categoryID)&limit=\(limit)&sort=POPULARITY&fields=fsq_place_id,name,latitude,longitude,location"
            )
        else { throw URLError(.badURL) }
        
        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        
        let rawPlaces = try JSONDecoder().decode(FSQResponse.self, from: data).results
        return rawPlaces
    }

    // MARK: - Autocomplete Location
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
        return fsqResponse.results.compactMap { result in
            guard let geoItem = result.geo else { return nil }
            let cityName = result.text.primary
            let detail = result.text.secondary ?? ""
            let fullName = detail.isEmpty ? cityName : "\(cityName), \(detail)"
            return FSQPlace(
                fsq_place_id: result.text.primary,
                name: fullName,
                distance: 0,
                location: nil,
                geocodes: FSQGeocodes(main: FSQCoordinate(
                    latitude: geoItem.center?.latitude ?? 0.0,
                    longitude: geoItem.center?.longitude ?? 0.0
                ))
            )
        }
    }
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
    let secondary: String?
}
private struct GeoWrapper: Codable { let center: CenterCoordinates? }
private struct CenterCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}
