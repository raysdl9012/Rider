//
//  ReviewServiceProtocol.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import Foundation
import FirebaseFirestore

protocol ReviewServiceProtocol {
    /// Guarda una nueva reseña y actualiza la calificación del conductor.
    func submitReview(_ review: ReviewEntity) async throws
}


class FirebaseReviewService: ReviewServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func submitReview(_ review: ReviewEntity) async throws {
        // 1. Guardar la reseña en una colección 'reviews'.
        try  db.collection(FIR_COLLECTION_REVIEWS).addDocument(from: review)
        // 2. Actualizar la calificación promedio del conductor.
        try await updateDriverRating(driverId: review.driverId)
    }
    
    /// Recalcula y actualiza la calificación promedio de un conductor.
    private func updateDriverRating(driverId: String) async throws {
        // Obtenemos todas las reseñas para este conductor.
        let reviewsSnapshot = try await db.collection("reviews")
            .whereField("driverId", isEqualTo: driverId)
            .getDocuments()
        
        let ratings = reviewsSnapshot.documents.compactMap { document in
            (document.data()["rating"] as? Double)
        }
        
        // Calculamos el nuevo promedio.
        let newAverageRating = ratings.isEmpty ? 0.0 : ratings.reduce(0, +) / Double(ratings.count)
        let newTotalRatings = ratings.count
        
        // Actualizamos el documento del conductor con la nueva calificación.
        try await db.collection("users").document(driverId).updateData([
            "averageRating": newAverageRating,
            "totalRatings": newTotalRatings
        ])
        
        print("✅ Driver rating updated. New average: \(newAverageRating), Total: \(newTotalRatings)")
    }
}
