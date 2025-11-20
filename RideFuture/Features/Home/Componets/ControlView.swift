//
//  ControlView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI

struct ControlView: View {
    
    @Binding var isShowingSearch: Bool
    @Binding var destination: MapDestinationEntity?
    
    var onRequestRide: () -> Void = { }
    
    var body: some View {
        HStack(spacing: 22) {
            
            // Botón de búsqueda con animación
            Button {
                isShowingSearch.toggle()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                ZStack {
                    Circle()
                        .fill(.thinMaterial)
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .scaleEffect(isShowingSearch ? 1.1 : 1.0)
                .animation(.spring(response: 0.35, dampingFraction: 0.72), value: isShowingSearch)
            }
            
            
            Button {
                onRequestRide()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))
                    
                    Text(destination == nil ? "Selecciona un destino" : "Solicitar RideFuture")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(destination == nil ? Color.gray.opacity(0.5) : Color.blue)
                )
                .shadow(
                    color: (destination == nil ? Color.clear : Color.blue.opacity(0.4)),
                    radius: 12, x: 0, y: 6
                )
                
            }
            .disabled(destination == nil)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 18, x: 0, y: -4)
        )
        .padding(.horizontal, 18)
        .padding(.bottom, 10)
        
    }
}

#Preview {
    ControlView(isShowingSearch: .constant(false), destination: .constant(nil))
}
