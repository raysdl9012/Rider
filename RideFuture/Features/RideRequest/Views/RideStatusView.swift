//
//  RideRequestVew.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore 

/// La vista principal que muestra el estado actual del viaje al pasajero.
struct RideStatusView: View {
    let rideRequest: RideRequestEntity
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(statusText)
                .font(.title2)
                .fontWeight(.bold)
            
            // Mostramos la información del conductor si está disponible.
            if let driverInfo = rideRequest.driverInfo {
                // *** AQUÍ SE USA DriverInfoView ***
                DriverInfoView(driverInfo: driverInfo)
            }
            
            Text("Hacia: \(rideRequest.destinationTitle)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
    }
    
    /// Calcula el texto a mostrar según el estado del viaje.
    private var statusText: String {
        switch rideRequest.status {
        case .requesting:
            return "Buscando tu conductor..."
        case .driverAssigned:
            return "¡Conductor asignado!"
        case .inProgress:
            return "Viaje en curso"
        case .completed:
            return "Viaje finalizado"
        case .cancelled:
            return "Viaje cancelado"
        }
    }
}

// *** AQUÍ SE DEFINEN LAS VISTAS AUXILIARES ***

/// Una vista para mostrar los detalles del conductor, incluyendo su calificación.
struct DriverInfoView: View {
    let driverInfo: DriverInfo
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder para la foto de perfil
            Circle()
                .fill(.quaternary)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(driverInfo.name)
                    .font(.headline)
                
                // *** AQUÍ SE USA StarRatingView ***
                HStack(spacing: 8) {
                    StarRatingView(rating: driverInfo.averageRating)
                    Text("(\(driverInfo.totalRatings))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(driverInfo.carModel) • \(driverInfo.licensePlate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

/// Un componente reutilizable para mostrar una calificación con estrellas.
struct StarRatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= Int(rating.rounded()) ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
    }
}


// MARK: - Preview

#Preview("Conductor Asignado") {
    let sampleRide = RideRequestEntity(
        id: "1",
        passengerId: "user-abc",
        pickupLocation: GeoPoint(latitude: 37.7749, longitude: -122.4194),
        destinationLocation: GeoPoint(latitude: 37.8044, longitude: -122.2711),
        status: .driverAssigned,
        destinationTitle: "Oracle Paˇrk",
        timestamp: Timestamp(date: Date()),
        driverInfo: DriverInfo(
            id: "driver-123",
            name: "Alex R.",
            carModel: "Tesla Model 3",
            licensePlate: "ABC-123",
            profileImageURL: nil,
            averageRating: 4.8,
            totalRatings: 125
        )
    )
    
    RideStatusView(rideRequest: sampleRide) {
        print("Cancel tapped")
    }
}


