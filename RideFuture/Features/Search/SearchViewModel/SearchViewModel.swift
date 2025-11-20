//
//  SearchViewModel.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import Foundation
import MapKit
internal import Combine

/// ViewModel para manejar la lógica de búsqueda de destinos.
/// Utiliza MKLocalSearchCompleter para obtener sugerencias de MapKit.
class SearchViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// La lista de resultados de la búsqueda que se mostrarán en la UI.
    @Published var searchResults: [MKLocalSearchCompletion] = []
    /// La consulta de búsqueda actual.
    @Published var searchQuery = ""
    
    // MARK: - Private Properties
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        // Nos suscribimos a los cambios en el texto de búsqueda.
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // Espera 300ms de inactividad antes de buscar.
            .removeDuplicates() // No busca si la consulta es la misma que la anterior.
            .sink { [weak self] query in
                self?.searchCompleter.queryFragment = query
            }
            .store(in: &cancellables)
        
        searchCompleter.delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Convierte un resultado de búsqueda (MKLocalSearchCompletion) en un elemento de mapa completo (MKMapItem).
    /// Esto es necesario para obtener las coordenadas exactas del lugar.
    func resolveLocation(for completion: MKLocalSearchCompletion) async throws -> MKMapItem {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()
        
        // Devuelve el primer elemento de la respuesta, que suele ser el más relevante.
        guard let mapItem = response.mapItems.first else {
            throw NSError(domain: "LocationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se encontró la ubicación"])
        }
        
        return mapItem
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension SearchViewModel: MKLocalSearchCompleterDelegate {
    /// Se llama cuando el completer de búsqueda encuentra nuevos resultados.
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Actualizamos los resultados en el hilo principal.
        Task {
            await MainActor.run {
                self.searchResults = completer.results
            }
        }
    }
    
    /// Se llama si ocurre un error durante la búsqueda.
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error en la búsqueda: \(error.localizedDescription)")
    }
}
