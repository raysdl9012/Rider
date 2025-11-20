//
//  PaymentTransactionEntity.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import Foundation
import FirebaseFirestore

/// Representa una transacción de pago completada.
struct PaymentTransactionEntity: Codable, Identifiable {
    @DocumentID var id: String?
    
    /// El ID del viaje al que corresponde este pago.
    let rideId: String
    
    /// El monto total del pago.
    let amount: Double
    
    /// El método de pago utilizado.
    let paymentMethod: PaymentMethod
    
    /// El estado de la transacción.
    let status: PaymentStatus
    
    /// La fecha en que se realizó el pago.
    let timestamp: Timestamp
    
    enum PaymentMethod: String, Codable, CaseIterable {
        case creditCard = "Tarjeta de Crédito"
        case cash = "Efectivo"
        case ridePay = "RideFuture Pay"
    }
    
    enum PaymentStatus: String, Codable {
        case pending = "pending"
        case succeeded = "succeeded"
        case failed = "failed"
    }
}
