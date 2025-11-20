//
//  PricingService.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import Foundation

/// Un servicio para calcular el precio de un viaje.
/// Para una demo, usamos un algoritmo simple.
class PricingService {
    
    // Parámetros de precios de demo
    private let baseFare: Double = 2.50 // Tarifa base
    private let costPerKilometer: Double = 1.20 // Costo por kilómetro
    private let costPerMinute: Double = 0.30 // Costo por minuto de tiempo
    
    /// Calcula el precio del viaje basado en la distancia y el tiempo.
    func calculatePrice(for estimation: TripEstimation) -> Double {
        let distancePrice = estimation.distanceInKilometers * costPerKilometer
        let timePrice = (estimation.expectedTravelTime / 60.0) * costPerMinute
        
        let totalPrice = baseFare + distancePrice + timePrice
        
        // Redondeamos a 2 decimales.
        return round(totalPrice * 100) / 100
    }
}
