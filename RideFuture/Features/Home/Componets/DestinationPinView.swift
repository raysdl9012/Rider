//
//  DestinationPinView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI

struct DestinationPinView: View {
    let title: String
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 6) {
            // BURBUJA CON EL TÍTULO
            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 3)
            
            // PIN PRINCIPAL
            ZStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 15, height: 15)

                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 10))
                    .offset(y: 10)
                    .foregroundColor(.blue)
            }
            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            .scaleEffect(appear ? 1.0 : 0.5)
            .opacity(appear ? 1.0 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                appear = true
            }
        }
    }
}


#Preview {
    DestinationPinView(title: "marcador")
}
