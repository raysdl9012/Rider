//
//  TripHistoryViewModel.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import Foundation
internal import Combine


class TripHistoryViewModel: ObservableObject {
    
    @Published var trips: [TripHistoryEntity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let historyService: TripHistoryServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(historyService: TripHistoryServiceProtocol) {
        self.historyService = historyService
        
        // Nos suscribimos al publicador del servicio.
        historyService.tripsPublisher
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] trips in
                self?.trips = trips
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    /// Carga los viajes del historial para un usuario específico.
    func loadTrips(for userId: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await historyService.fetchTrips(for: userId)
            } catch {
                self.errorMessage = "Error al cargar el historial: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
