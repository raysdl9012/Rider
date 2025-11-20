//
//  RideSimulationPanel.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI

/// Un panel de control para simular las acciones de un conductor.
/// Solo se muestra con fines de demostración.
struct RideSimulationPanel: View {
    
    @ObservedObject var rideRequestViewModel: RideRequestViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Panel de Simulación (Demo)")
                .font(.caption)
                .foregroundColor(.indigo)
            
            // Mostramos botones diferentes según el estado actual del viaje.
            switch rideRequestViewModel.currentRideRequest?.status {
            case .requesting:
                simulationButton(title: "Simular Conductor Acepta") {
                    Task {
                        await rideRequestViewModel.simulateDriverAcceptance()
                    }
                }
            case .driverAssigned:
                simulationButton(title: "Simular Inicio de Viaje") {
                    Task {
                        await rideRequestViewModel.simulateTripStart()
                    }
                }
                simulationButton(title: "Simular Cancelación", action: {
                    Task {
                        await rideRequestViewModel.simulateCancellation()
                    }
                }, style: .destructive)
            case .inProgress:
                simulationButton(title: "Simular Finalización de Viaje") {
                    Task {
                        await rideRequestViewModel.simulateTripCompletion()
                    }
                }
            case .completed, .cancelled, .none:
                EmptyView()
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func simulationButton(title: String, action: @escaping () -> Void, style: Style = .primary) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(style == .destructive ? .white : .white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(style == .destructive ? .red : .blue,
                            in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    enum Style {
        case primary
        case destructive
    }
}

#Preview {
    // Necesitamos un RideRequestViewModel de ejemplo para el preview.
    let vm = RideRequestViewModel(
        rideRequestService: FirebaseRideRequestService(),
        authViewModel: AuthViewModel(authService: FirebaseAuthenticationService())
    )
    // Simulamos un estado para ver cómo se ve el panel.
    // vm.currentRideRequest = RideRequestEntity.sampleRequesting // Descomenta para probar
    
    return RideSimulationPanel(rideRequestViewModel: vm)
        .background(.black.opacity(0.9))
}
