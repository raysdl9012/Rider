//
//  RatingView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 19/11/25.
//

import SwiftUI
import FirebaseCore

struct RatingView: View {
    let driverInfo: DriverInfo
    let onDismiss: () -> Void
    
    @State private var rating = 3.0
    @State private var comment = ""
    @State private var isSubmitting = false
    @EnvironmentObject private var authViewmodel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Información del Conductor
                VStack(spacing: 12) {
                    Text("¿Cómo fue tu viaje?")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Califica tu experiencia con \(driverInfo.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Selector de Estrellas
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(rating.rounded()) ? "star.fill" : "star")
                            .font(.largeTitle)
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    rating = Double(star)
                                }
                            }
                    }
                }
                
                // Campo de Comentario
                TextField("Deja un comentario (opcional)", text: $comment, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...5)
                
                Spacer()
                
                // Botón de Enviar
                Button(action: submitReview) {
                    Text("Enviar Valoración")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue, in: RoundedRectangle(cornerRadius: 15))
                }
                .disabled(isSubmitting)
            }
            .padding()
            .navigationTitle("Valorar Conductor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Omitir") {
                        onDismiss()
                    }
                }
            }
        }
        .overlay {
            if isSubmitting {
                ProgressView("Enviando...")
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
            }
        }
    }
    
    private func submitReview() {
        isSubmitting = true
        
        Task {
            do {
                let review = ReviewEntity(
                    reviewerId: authViewmodel.currentUser?.id ?? "",
                    driverId: driverInfo.id,
                    rating: rating,
                    comment: comment.isEmpty ? nil : comment,
                    timestamp: Timestamp(date: Date())
                )
                let reviewService = FirebaseReviewService()
                try await reviewService.submitReview(review)
                onDismiss()
                
            } catch {
                onDismiss()
            }
            
            isSubmitting = false
        }
    }
}

#Preview {
    let sampleDriver = DriverInfo(id: "1", name: "Alex R.", carModel: "Tesla Model 3", licensePlate: "ABC-123", profileImageURL: nil, averageRating: 4.8, totalRatings: 125)
    return RatingView(driverInfo: sampleDriver) {
        print("Dismissed")
    }
}
