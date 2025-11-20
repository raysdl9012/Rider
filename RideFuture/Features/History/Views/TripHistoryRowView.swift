//
//  TripHistoryRowView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import SwiftUI

/// Una vista para una sola fila en la lista del historial de viajes.
struct TripHistoryRowView: View {
    let trip: TripHistoryEntity
    
    var body: some View {
        HStack(spacing: 15) {
            // Ícono del viaje
            ZStack {
                Circle()
                    .fill(.quaternary)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "car.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            // Información principal del viaje
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.destinationAddress)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(trip.pickupAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text("\(trip.driverName) • \(trip.carModel)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Precio del viaje
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(trip.formattedPrice)")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(trip.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    let sampleTrip = TripHistoryEntity(
        id: "1",
        date: Date(),
        pickupAddress: "123 Main St",
        destinationAddress: "456 Oak Ave",
        driverName: "Alex R.",
        carModel: "Tesla Model 3",
        finalPrice: 25.50
    )
    
    return TripHistoryRowView(trip: sampleTrip)
        .padding()
}
