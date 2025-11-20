//
//  TripEstimationView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import SwiftUI

import SwiftUI

/// Una vista para mostrar la estimación de precio y tiempo del viaje.
struct TripEstimationView: View {
    let estimation: TripEstimation
    let price: Double
    
    var body: some View {
        HStack(spacing: 20) {
            // Vista para el tiempo
            VStack(alignment: .leading, spacing: 4) {
                Text("Tiempo estimado")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(estimation.formattedDuration)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Divider()
                .frame(height: 30)
            
            // Vista para el precio
            VStack(alignment: .leading, spacing: 4) {
                Text("Precio estimado")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("$\(price, specifier: "%.2f")")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let estimation = TripEstimation(distanceInMeters: 5000, expectedTravelTime: 900) // 5km, 15 mins
    let price = PricingService().calculatePrice(for: estimation)
    
    return TripEstimationView(estimation: estimation, price: price)
        .padding()
}
