//
//  LocationServiceProtocol.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    var currentLocation: CLLocationCoordinate2D? { get }
    func requestLocationPermission()
}
