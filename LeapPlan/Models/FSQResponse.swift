//
//  FSQResponse.swift
//  LeapPlan
//
//  Created by Wesley Goey on 31/05/26.
//


import Foundation
import CoreLocation

// MARK: - API Response Wrapper
struct FSQResponse: Codable {
    let results: [FSQPlace]
}
