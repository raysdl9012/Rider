//
//  AuthTextField.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI

/// Un componente de campo de texto reutilizable para la autenticación.
/// Sigue el estilo de diseño "iOS 26" con un fondo de material translúcido.
struct AuthTextField: View {
    
    @Binding var text: String
    
    var title: String
    var placeholder: String
    var isSecureField: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Group {
                if isSecureField {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
    }
}


#Preview {
    AuthTextField(text: .constant(""), title: "Enter your data", placeholder: "enter your field")
}
