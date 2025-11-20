//
//  RideRequestEntity.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import Foundation
import FirebaseFirestore
import CoreLocation


// Estructura para representar la información del conductor.
/// Estructura para representar la información del conductor.
struct DriverInfo: Codable {
    let id: String
    let name: String
    let carModel: String
    let licensePlate: String
    let profileImageURL: String?
    let averageRating: Double
    let totalRatings: Int
}

struct RideRequestEntity: Codable, Identifiable {
    
    @DocumentID var id: String?
    let passengerId: String
    let pickupLocation: GeoPoint
    let destinationLocation: GeoPoint
    let status: RideStatus
    let destinationTitle: String
    let timestamp: Timestamp
    
    // *** NUEVO ***: Información del conductor. Es opcional porque no existe al principio.
    let driverInfo: DriverInfo?
    
    // Enum para los posibles estados de un viaje.
    enum RideStatus: String, Codable {
        case requesting = "requesting"       // Buscando conductor
        case driverAssigned = "driver_assigned" // Conductor asignado
        case inProgress = "in_progress"       // Viaje en curso
        case completed = "completed"         // Viaje finalizado
        case cancelled = "cancelled"          // Viaje cancelado
    }
}


extension RideRequestEntity {
    
    /// Datos de ejemplo para un viaje que está buscando conductor.
    static let sampleRequesting = RideRequestEntity(
        id: "ride-requesting-123",
        passengerId: "user-abc",
        pickupLocation: GeoPoint(latitude: 37.7749, longitude: -122.4194), // San Francisco City Hall
        destinationLocation: GeoPoint(latitude: 37.8044, longitude: -122.2711), // Oracle Park
        status: .requesting,
        destinationTitle: "Oracle Park",
        timestamp: Timestamp(date: Date()),
        driverInfo: nil
    )
    
    /// Datos de ejemplo para un viaje con conductor ya asignado.
    static let sampleDriverAssigned = RideRequestEntity(
        id: "ride-assigned-456",
        passengerId: "user-def",
        pickupLocation: GeoPoint(latitude: 37.3382, longitude: -121.8863), // San Jose
        destinationLocation: GeoPoint(latitude: 37.4419, longitude: -122.1430), // Palo Alto
        status: .driverAssigned,
        destinationTitle: "Stanford University",
        timestamp: Timestamp(date: Date()),
        driverInfo: nil
    )
    
    /// Datos de ejemplo para un viaje que está en curso.
    static let sampleInProgress = RideRequestEntity(
        id: "ride-in-progress-789",
        passengerId: "user-ghi",
        pickupLocation: GeoPoint(latitude: 34.0522, longitude: -118.2437), // Los Angeles
        destinationLocation: GeoPoint(latitude: 34.0194, longitude: -118.4912), // Santa Mónica
        status: .inProgress,
        destinationTitle: "Santa Monica Pier",
        timestamp: Timestamp(date: Date()),
        driverInfo: nil
    )
}


