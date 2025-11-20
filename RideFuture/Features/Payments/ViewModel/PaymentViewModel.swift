//
//  PaymentViewModel.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import Foundation
internal import Combine


class PaymentViewModel: ObservableObject {
    
    @Published var selectedPaymentMethod: PaymentTransactionEntity.PaymentMethod = .ridePay
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    // *** NUEVO ***: Propiedad publicada para que la Vista pueda observar el éxito del pago.
    @Published var paymentSucceeded = false
    
    private let paymentService: PaymentServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(paymentService: PaymentServiceProtocol) {
        self.paymentService = paymentService
        
        // Nos suscribimos al servicio directamente en el ViewModel.
        paymentService.transactionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transaction in
                if transaction != nil {
                    self?.paymentSucceeded = true
                }
            }
            .store(in: &cancellables)
    }
    
    func processPayment(for rideId: String, amount: Double, userId: String) {
        isProcessing = true
        errorMessage = nil
        paymentSucceeded = false // Reseteamos el estado de éxito
        
        Task {
            do {
                try await paymentService.processPayment(for: rideId, amount: amount, method: selectedPaymentMethod, userId:userId)
            } catch {
                self.errorMessage = "Error al procesar el pago: \(error.localizedDescription)"
            }
            await MainActor.run {
                isProcessing = false
            }
            
        }
    }
}
