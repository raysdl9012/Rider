//
//  TripHistoryEntity.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import Foundation

import Foundation
import FirebaseFirestore // Importamos para usar GeoPoint y Timestamp

struct TripHistoryEntity: Identifiable, Codable {
    let id: String
    let date: Date
    let pickupAddress: String
    let destinationAddress: String
    let driverName: String
    let carModel: String
    let finalPrice: Double
    
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Formatea el precio con el símbolo de la moneda.
    var formattedPrice: String {
        return String(format: "%.2f", finalPrice)
    }
    
    
    // *** NUEVO ***: Inicializador para decodificar manualmente desde un documento de Firestore.
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let id = document.documentID as String?,
              let timestamp = data["date"] as? Timestamp,
              let pickupAddress = data["pickupAddress"] as? String,
              let destinationAddress = data["destinationAddress"] as? String,
              let driverName = data["driverName"] as? String,
              let carModel = data["carModel"] as? String,
              let finalPrice = data["finalPrice"] as? Double else {
            print("❌ Error: Failed to decode TripHistoryEntity from document: \(document.documentID)")
            return nil
        }
        
        self.id = id
        self.date = timestamp.dateValue() // *** CLAVE: Convertimos Timestamp a Date ***
        self.pickupAddress = pickupAddress
        self.destinationAddress = destinationAddress
        self.driverName = driverName
        self.carModel = carModel
        self.finalPrice = finalPrice
    }
    
    // Mantenemos el inicializador estándar para cuando creamos el objeto para guardarlo.
    init(id: String, date: Date, pickupAddress: String, destinationAddress: String, driverName: String, carModel: String, finalPrice: Double) {
        self.id = id
        self.date = date
        self.pickupAddress = pickupAddress
        self.destinationAddress = destinationAddress
        self.driverName = driverName
        self.carModel = carModel
        self.finalPrice = finalPrice
    }
}
