//
//  FirebaseTripHistoryService.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import Foundation
import FirebaseFirestore
internal import Combine


protocol TripHistoryServiceProtocol {
    /// Un publicador que emite la lista de viajes del historial.
    var tripsPublisher: AnyPublisher<[TripHistoryEntity], Error> { get }
    
    /// Obtiene los viajes del historial de un usuario desde Firestore.
    func fetchTrips(for userId: String) async throws
}

class FirebaseTripHistoryService: TripHistoryServiceProtocol {
    
    private let db = Firestore.firestore()
    private var tripsSubject = CurrentValueSubject<[TripHistoryEntity], Error>([])
    
    var tripsPublisher: AnyPublisher<[TripHistoryEntity], Error> {
        tripsSubject.eraseToAnyPublisher()
    }
    
    func fetchTrips(for userId: String) async throws {
        let tripsCollection = db.collection(FIR_COLLECTION_USERS).document(userId).collection(FIR_COLLECTION_TRIP_HISTORY)
            .order(by: "date", descending: true)
        
        let snapshot = try await tripsCollection.getDocuments()
        let trips = snapshot.documents.compactMap { document -> TripHistoryEntity? in
            TripHistoryEntity(document: document)
        }
        
        // Publicamos los viajes en el hilo principal.
        Task { @MainActor in
            self.tripsSubject.send(trips)
        }
    }
}
