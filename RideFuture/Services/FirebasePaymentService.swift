//
//  FirebasePaymentService.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import Foundation
import FirebaseFirestore
internal import Combine

protocol PaymentServiceProtocol {
    /// Un publicador que emite el resultado de la transacción.
    var transactionPublisher: AnyPublisher<PaymentTransactionEntity?, Never> { get }
    
    /// Procesa el pago para un viaje específico.
    func processPayment(for rideId: String, amount: Double, method: PaymentTransactionEntity.PaymentMethod, userId: String) async throws
}

import Foundation
import FirebaseFirestore


class FirebasePaymentService: PaymentServiceProtocol {
    
    private let db = Firestore.firestore()
    
    // Usamos un PassthroughSubject porque un pago es un evento único.
    private let transactionSubject = PassthroughSubject<PaymentTransactionEntity?, Never>()
    
    var transactionPublisher: AnyPublisher<PaymentTransactionEntity?, Never> {
        transactionSubject.eraseToAnyPublisher()
    }
    
    func processPayment(for rideId: String, amount: Double, method: PaymentTransactionEntity.PaymentMethod, userId: String) async throws {
        print("💳 Processing payment for ride: \(rideId)...")
        
        // *** SIMULACIÓN ***: Simulamos un retraso de red de 2 segundos.
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Creamos la entidad de la transacción con estado "succeeded".
        let transaction = PaymentTransactionEntity(
            rideId: rideId,
            amount: amount,
            paymentMethod: method,
            status: .succeeded,
            timestamp: Timestamp(date: Date())
        )
    
        try db.collection(FIR_COLLECTION_USERS).document(userId).collection(FIR_COLLECTION_PAYMENTS).addDocument(from: transaction)
        
        print("✅ Payment succeeded and saved for ride: \(rideId)")
        
        // Emitimos el resultado para que el ViewModel pueda reaccionar.
        Task { @MainActor in
            self.transactionSubject.send(transaction)
        }
    }
}


