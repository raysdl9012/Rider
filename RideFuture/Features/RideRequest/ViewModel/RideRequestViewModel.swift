//
//  RideRequestViewModel.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import Foundation
import CoreLocation
internal import Combine


class RideRequestViewModel: ObservableObject {
    
    @Published var currentRideRequest: RideRequestEntity?
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let rideFinishedSubject = PassthroughSubject<Void, Never>()
    // *** SIMPLIFICACIÓN ***: Ya no necesitamos el servicio de simulación.
    // Mantenemos el servicio de solicitudes para la creación inicial.
    private let rideRequestService: RideRequestServiceProtocol
    private let authViewModel: AuthViewModel
    private var cancellables = Set<AnyCancellable>()
    
    
    var rideFinishedPublisher: AnyPublisher<Void, Never> {
        rideFinishedSubject.eraseToAnyPublisher()
    }
    
    // *** SIMPLIFICACIÓN ***: El inicializador ya no necesita el servicio de simulación.
    init(rideRequestService: RideRequestServiceProtocol, authViewModel: AuthViewModel) {
        self.rideRequestService = rideRequestService
        self.authViewModel = authViewModel
        
        rideRequestService.currentRideRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rideRequest in
                self?.currentRideRequest = rideRequest
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    func requestRide(pickup: CLLocationCoordinate2D, destination: MapDestinationEntity) {
        // ... (El método de solicitud inicial permanece igual, ya que SÍ debe escribir en la base de datos) ...
        guard let passengerId = authViewModel.currentUser?.id else {
            self.errorMessage = "Usuario no autenticado."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await rideRequestService.createRide(
                    pickup: pickup,
                    destination: destination.coordinate,
                    destinationTitle: destination.title,
                    passengerId: passengerId
                )
            } catch {
                self.errorMessage = "Error al solicitar el viaje: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func simulateDriverAcceptance() async {
        guard let ride = self.currentRideRequest,
                let id = ride.id, ride.status == .requesting else { return }
        
        let mockDriver = DriverInfo(
            id: "driver-123",
            name: "Alex R.",
            carModel: "Tesla Model 3",
            licensePlate: "ABC-123",
            profileImageURL: nil,
            averageRating: 4.8,
            totalRatings: 125
        )
        
        do {
            try await rideRequestService.assignDriver(to: id, driverInfo: mockDriver)
        } catch {
            self.errorMessage = "Error al simular aceptación: \(error.localizedDescription)"
        }
    }
    
    func simulateTripStart() async {
        guard let ride = self.currentRideRequest, let id = ride.id, ride.status == .driverAssigned else { return }
        
        do {
            try await rideRequestService.updateStatus(for: id, to: .inProgress)
        } catch {
            self.errorMessage = "Error al simular inicio: \(error.localizedDescription)"
        }
    }
    
    // *** CORREGIDO ***: Ahora llama al servicio y es asíncrono.
    func simulateTripCompletion() async {
        guard let rideId = self.currentRideRequest?.id else { return }
        
        do {
            try await rideRequestService.updateStatus(for: rideId, to: .completed)
            rideFinishedSubject.send()
            self.currentRideRequest = nil
        } catch {
            self.errorMessage = "Error al simular finalización: \(error.localizedDescription)"
        }
    }
    
    // *** CORREGIDO ***: Ahora llama al servicio y es asíncrono.
    func simulateCancellation() async {
        guard let rideId = self.currentRideRequest?.id else { return }
        
        do {
            try await rideRequestService.updateStatus(for: rideId, to: .cancelled)
            rideFinishedSubject.send()
            self.currentRideRequest = nil
        } catch {
            self.errorMessage = "Error al simular cancelación: \(error.localizedDescription)"
        }
    }
    
    func restoreActiveRide(for passengerId: String) async ->  RideRequestEntity? {
        do {
            if let activeRide = try await rideRequestService.fetchActiveRide(for: passengerId) {
                // Si se encuentra un viaje, lo asignamos.
                self.currentRideRequest = activeRide
                return currentRideRequest
            }
        } catch {
            print("❌ Error fetching active ride: \(error.localizedDescription)")
            
        }
        return nil
    }
}
