//
//  TripHistoryView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import SwiftUI


import SwiftUI

/// La vista principal que muestra la lista del historial de viajes completados.
struct TripHistoryView: View {
    
    // *** NUEVO ***: Usamos el ViewModel para gestionar el estado.
    @StateObject private var viewModel: TripHistoryViewModel
    
    // Necesitamos el ID del usuario para cargar su historial.
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // *** ACTUALIZADO ***: El inicializador ahora crea el ViewModel.
    init() {
        let historyService = FirebaseTripHistoryService()
        _viewModel = StateObject(wrappedValue: TripHistoryViewModel(historyService: historyService))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando historial...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.trips.isEmpty {
                    Text("Aún no tienes viajes en tu historial.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.trips) { trip in
                            TripHistoryRowView(trip: trip)
                        }
                    }
                }
            }
            .navigationTitle("Historial de Viajes")
            .navigationBarTitleDisplayMode(.large)
            .task {
                // Carga los viajes cuando la vista aparece.
                if let userId = authViewModel.currentUser?.id {
                    viewModel.loadTrips(for: userId)
                }
            }
        }
    }
}

#Preview {
    TripHistoryView()
        .environmentObject(AuthViewModel(authService: FirebaseAuthenticationService()))
}
