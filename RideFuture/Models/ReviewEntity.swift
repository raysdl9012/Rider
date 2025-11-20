//
//  ReviewEntity.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import Foundation
import FirebaseFirestore

/// Representa una reseña dejada por un pasajero a un conductor.
struct ReviewEntity: Codable, Identifiable {
    @DocumentID var id: String?
    /// El ID del usuario que deja la reseña.
    let reviewerId: String
    /// El ID del conductor que recibe la reseña.
    let driverId: String
    /// La calificación en estrellas (de 1.0 a 5.0).
    let rating: Double
    /// El comentario de texto (opcional).
    let comment: String?
    /// La fecha en que se dejó la reseña.
    let timestamp: Timestamp
}
