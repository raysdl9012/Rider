//
//  MapDestinationeNTITY.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import _LocationEssentials

struct MapDestinationEntity: Identifiable, Equatable {
    let id = UUID()          
    let title: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: MapDestinationEntity, rhs: MapDestinationEntity) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.title == rhs.title
    }
}
