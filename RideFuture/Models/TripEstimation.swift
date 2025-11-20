//
//  TripEstimation.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import Foundation
import CoreLocation

struct TripEstimation {
    let distanceInMeters: CLLocationDistance
    let expectedTravelTime: TimeInterval // En segundos
    
    var distanceInKilometers: Double {
        return distanceInMeters / 1000.0
    }
    
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: expectedTravelTime) ?? "N/A"
    }
}
