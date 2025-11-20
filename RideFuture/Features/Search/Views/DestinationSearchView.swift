//
//  DestinationSearchView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI
import MapKit

/// Vista para buscar y seleccionar un destino.
/// Se presenta como una hoja modal (.sheet).
struct DestinationSearchView: View {
    
    // MARK: - State Objects & Bindings
    
    @StateObject private var searchViewModel = SearchViewModel()
    
    /// Un binding para comunicar el destino seleccionado de vuelta a la vista que la presenta (HomeView).
    @Binding var selectedDestination: MapDestinationEntity?
    
    /// Controla si la vista está presente o no.
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - Smart Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                    
                    TextField("¿A dónde vamos?", text: $searchViewModel.searchQuery)
                        .font(.system(size: 17))
                        .padding(.vertical, 8)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.sentences)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal)
                .padding(.top, 12)
                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                .animation(.spring(response: 0.30,
                                   dampingFraction: 0.75),
                           value: searchViewModel.searchQuery)
                
                // MARK: - Results List (modern style)
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchViewModel.searchResults, id: \.self) { completion in
                            DestinationSearchResultCard(completion: completion) {
                                onClickItem(completion: completion)
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .animation(.easeInOut(duration: 0.25),
                               value: searchViewModel.searchResults)
                }
                
                Spacer(minLength: 0)
            }
            .navigationTitle("Buscar Destino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancelar")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
}


extension DestinationSearchView {
    // Cuando se toca una fila, resolvemos la ubicación y la asignamos.
    private func onClickItem(completion: MKLocalSearchCompletion){
        Task {
            do {
                let mapItem = try await searchViewModel.resolveLocation(for: completion)
                let destination = MapDestinationEntity(
                    title: mapItem.name ?? "Destino",
                    coordinate: mapItem.placemark.coordinate
                )
                await MainActor.run {
                    selectedDestination = destination
                    dismiss()
                }
            } catch {
                print("Error al resolver la ubicación: \(error)")
                // Aquí podrías mostrar una alerta al usuario.
            }
        }
    }
}


#Preview {
    DestinationSearchView(selectedDestination: .constant(MapDestinationEntity(title: "",
                                                                              coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))))
}
