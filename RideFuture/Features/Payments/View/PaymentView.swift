//
//  PaymentView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import SwiftUI

struct PaymentView: View {
    
    let rideRequest: RideRequestEntity
    let finalPrice: Double
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: PaymentViewModel = PaymentViewModel(paymentService: FirebasePaymentService())
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showRatingView = false
    @State private var driverForRating: DriverInfo?
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Resumen del Viaje
                VStack(alignment: .leading, spacing: 12) {
                    Text("Resumen del Viaje")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.green)
                        Text(rideRequest.destinationTitle)
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15))
                
                // Total a Pagar
                VStack(spacing: 8) {
                    Text("Total a Pagar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("$\(finalPrice, specifier: "%.2f")")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                }
                
                // Métodos de Pago
                VStack(alignment: .leading, spacing: 16) {
                    Text("Método de Pago")
                        .font(.headline)
                    
                    Picker("Método de Pago", selection: $viewModel.selectedPaymentMethod) {
                        ForEach(PaymentTransactionEntity.PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15))
                
                Spacer()
                
                // Botón de Pagar
                Button(action: {
                    viewModel.processPayment(for: rideRequest.id ?? "",
                                             amount: finalPrice,
                                             userId: authViewModel.currentUser?.id ?? "")
                }) {
                    Text("Pagar \(viewModel.selectedPaymentMethod.rawValue)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue, in: RoundedRectangle(cornerRadius: 15))
                }
                .disabled(viewModel.isProcessing)
            }
            .padding()
            .navigationTitle("Pagar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if viewModel.isProcessing {
                    ProgressView("Procesando pago...")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 10)
                }
            }
            .alert("Error de Pago", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "Error desconocido")
            }
            // *** MODIFICADO ***: Ahora, en lugar de cerrar, mostramos la vista de valoración.
            .onChange(of: viewModel.paymentSucceeded) { succeeded in
                if succeeded {
                    print("✅ Payment succeeded. Showing rating view.")
                    self.driverForRating = rideRequest.driverInfo
                    self.showRatingView = true
                }
            }
            // *** NUEVO ***: Presentamos la RatingView como un fullScreenCover.
            .fullScreenCover(isPresented: $showRatingView) {
                if let driverInfo = driverForRating {
                    RatingView(driverInfo: driverInfo) {
                        // *** IMPORTANTE ***: Limpiamos el estado al cerrar para la próxima vez.
                        self.driverForRating = nil
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PaymentView(
            rideRequest: RideRequestEntity.sampleDriverAssigned,
            finalPrice: 25.50
        )
    }
}
