//
//  DestinationMarkerView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI

/// Una vista de marcador personalizado y con estilo para el destino en el mapa.
struct DestinationMarkerView: View {
    var body: some View {
        ZStack {
            // Círculo de fondo con un efecto de material
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 40, height: 40)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            // Ícono de destino
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(.red.gradient)
        }
    }
}

#Preview {
    DestinationMarkerView()
        .padding()
        .background(Color.gray.opacity(0.3))
}
