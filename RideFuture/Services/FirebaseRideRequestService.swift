//
//  FirebaseRideRequestService.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
internal import Combine


protocol RideRequestServiceProtocol {
    /// Un publicador que emite la solicitud de viaje actual o nil si no hay ninguna.
    var currentRideRequestPublisher: AnyPublisher<RideRequestEntity?, Never> { get }
    /// Crea una nueva solicitud de viaje en Firestore.
    func createRide(pickup: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, destinationTitle: String, passengerId: String) async throws
    func stopListeningForRideUpdates()
    func fetchActiveRide(for passengerId: String) async throws -> RideRequestEntity?
    func assignDriver(to rideId: String, driverInfo: DriverInfo) async throws
    func updateStatus(for rideId: String, to newStatus: RideRequestEntity.RideStatus) async throws
    func updateDriverLocation(for rideId: String, location: GeoPoint) async throws
}

class FirebaseRideRequestService: RideRequestServiceProtocol {
    
    private let db = Firestore.firestore()
    private var rideRequestListener: ListenerRegistration?
    
    // Usamos un CurrentValueSubject para emitir el estado actual de la solicitud de viaje.
    private var currentRideRequestSubject = CurrentValueSubject<RideRequestEntity?, Never>(nil)
    
    var currentRideRequestPublisher: AnyPublisher<RideRequestEntity?, Never> {
        currentRideRequestSubject.eraseToAnyPublisher()
    }
    
    func createRide(pickup: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, destinationTitle: String, passengerId: String) async throws {
        // Detenemos cualquier listener anterior
        stopListeningForRideUpdates()
        
        // 1. Crear el diccionario de datos para la nueva solicitud
        let rideData: [String: Any] = [
            "passengerId": passengerId,
            "pickupLocation": GeoPoint(latitude: pickup.latitude, longitude: pickup.longitude),
            "destinationLocation": GeoPoint(latitude: destination.latitude, longitude: destination.longitude),
            "destinationTitle": destinationTitle,
            "status": RideRequestEntity.RideStatus.requesting.rawValue,
            "timestamp": Timestamp(date: Date())
        ]
        
        // 2. Escribir el nuevo documento en la colección "rides"
        let docRef = try await db.collection("rides").addDocument(data: rideData)
        print("✅ Ride request created with ID: \(docRef.documentID)")
        
        // 3. Empezar a escuchar los cambios en este documento específico
        listenForRideUpdates(rideId: docRef.documentID)
    }
    
    /// Escucha los cambios en tiempo real de un documento de solicitud de viaje.
    private func listenForRideUpdates(rideId: String) {
        rideRequestListener = db.collection(FIR_COLLECTION_RIDES).document(rideId).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching ride document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                // Intenta decodificar el documento a nuestro modelo RideRequestEntity
                let rideRequest = try document.data(as: RideRequestEntity.self)
                if rideRequest.status == .completed {
                    Task {
                        try await self?.saveCompletedRideToHistory(rideRequest)
                    }
                }
                self?.currentRideRequestSubject.send(rideRequest)
            } catch {
                print("Error decoding ride request: \(error.localizedDescription)")
            }
        }
    }
    
    /// Detiene el listener para evitar actualizaciones innecesarias y memory leaks.
    func stopListeningForRideUpdates() {
        rideRequestListener?.remove()
        rideRequestListener = nil
        currentRideRequestSubject.send(nil) // Limpia el estado actual
    }
    
    func fetchActiveRide(for passengerId: String) async throws -> RideRequestEntity? {
        // Buscamos en Firestore un documento que coincida con el ID del pasajero
        // y cuyo estado sea "requesting", "driver_assigned" o "in_progress".
        let query = db.collection(FIR_COLLECTION_RIDES)
            .whereField("passengerId", isEqualTo: passengerId)
            .whereField("status", in: [
                RideRequestEntity.RideStatus.requesting.rawValue,
                RideRequestEntity.RideStatus.driverAssigned.rawValue,
                RideRequestEntity.RideStatus.inProgress.rawValue
            ])
            .limit(to: 1) // Solo nos interesa el viaje más reciente.
        
        let querySnapshot = try await query.getDocuments()
        
        guard let document = querySnapshot.documents.first else {
            return nil // No se encontró ningún viaje activo.
        }
        
        // Decodificamos el documento a nuestro modelo.
        let rideRequest = try document.data(as: RideRequestEntity.self)
        
        // Si encontramos un viaje, empezamos a escuchar sus actualizaciones.
        listenForRideUpdates(rideId: document.documentID)
        
        return rideRequest
    }
    
    
    func assignDriver(to rideId: String, driverInfo: DriverInfo) async throws {
        try await db.collection("rides").document(rideId).updateData([
            "status": RideRequestEntity.RideStatus.driverAssigned.rawValue,
            "driverInfo": try Firestore.Encoder().encode(driverInfo)
        ])
        print("✅ Ride \(rideId) status updated to driverAssigned.")
    }
    
    
    func updateStatus(for rideId: String, to newStatus: RideRequestEntity.RideStatus) async throws {
        try await db.collection("rides").document(rideId).updateData([
            "status": newStatus.rawValue
        ])
        print("✅ Ride \(rideId) status updated to: \(newStatus.rawValue)")
    }
    
    
    func updateDriverLocation(for rideId: String, location: GeoPoint) async throws {
        try await db.collection("rides").document(rideId).updateData([
            "driverCurrentLocation": location
        ])
    }
    
    private func saveCompletedRideToHistory(_ ride: RideRequestEntity) async throws {
        let passengerId = ride.passengerId
        guard let driverInfo = ride.driverInfo else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing passenger or driver info."])
        }
        
        // Convertimos las ubicaciones de GeoPoint a direcciones (simulado para la demo).
        let pickupAddress = "Dirección de recogida" // En una app real, usarías Geocoding.
        let destinationAddress = ride.destinationTitle
        
        // Creamos la entidad del historial.
        let historyEntry = TripHistoryEntity(
            id: ride.id ?? UUID().uuidString,
            date: Date(), // La fecha de finalización.
            pickupAddress: pickupAddress,
            destinationAddress: destinationAddress,
            driverName: driverInfo.name,
            carModel: driverInfo.carModel,
            finalPrice: 25.50 // En una app real, este precio vendría del viaje.
        )
        
        
        do {
            try await db.collection(FIR_COLLECTION_USERS).document(passengerId).collection(FIR_COLLECTION_TRIP_HISTORY).document(historyEntry.id).setData([
                "date": Timestamp(date: historyEntry.date),
                "pickupAddress": historyEntry.pickupAddress,
                "destinationAddress": historyEntry.destinationAddress,
                "driverName": historyEntry.driverName,
                "carModel": historyEntry.carModel,
                "finalPrice": historyEntry.finalPrice
            ])
            
            // *** CLAVE ***: El log de éxito solo se imprime DESPUÉS de que 'setData' se completa.
            print("✅ Trip successfully saved to history for user: \(passengerId)")
            
        } catch {
            // Si hay un error, lo imprimimos con detalles y lo propagamos hacia arriba.
            print("❌ ERROR: Could not save trip to history for user \(passengerId). Error: \(error.localizedDescription)")
            throw error // Propaga el error para que el listener lo maneje.
        }
    }
    
    
    deinit {
        stopListeningForRideUpdates()
    }
}
