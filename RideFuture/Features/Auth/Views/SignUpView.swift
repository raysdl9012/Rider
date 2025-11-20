//
//  SignUpView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI

/// Vista para que los nuevos usuarios creen una cuenta.
struct SignUpView: View {
    
    // MARK: - Environment Objects
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // MARK: - State Properties
    @State private var fullname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingErrorAlert = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.purple.opacity(0.1), .pink.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView { // Usamos ScrollView por si el teclado tapa contenido
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 60))
                                .foregroundStyle(.purple.gradient)
                            Text("Crea tu Cuenta")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 20) {
                            AuthTextField(
                                text: $fullname,
                                title: "Nombre Completo",
                                placeholder: "Juan Pérez"
                            )
                            
                            AuthTextField(
                                text: $email,
                                title: "Email",
                                placeholder: "tu@email.com"
                            )
                            
                            AuthTextField(
                                text: $password,
                                title: "Contraseña",
                                placeholder: "Mínimo 6 caracteres",
                                isSecureField: true
                            )
                            
                            AuthTextField(
                                text: $confirmPassword,
                                title: "Confirmar Contraseña",
                                placeholder: "Repite tu contraseña",
                                isSecureField: true
                            )
                            
                            Button(action: signUp) {
                                Text("Regístrate")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.purple.gradient, in: RoundedRectangle(cornerRadius: 15))
                            }
                            .disabled(authViewModel.isLoading || !isFormValid)
                            .opacity(authViewModel.isLoading || !isFormValid ? 0.6 : 1.0)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        HStack {
                            Text("¿Ya tienes una cuenta?")
                                .foregroundColor(.secondary)
                            NavigationLink("Inicia Sesión") {
                                LoginView()
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                        }
                        .padding(.bottom, 20)
                    }
                }
                
                if authViewModel.isLoading {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: authViewModel.errorMessage) { errorMessage in
                if errorMessage != nil {
                    showingErrorAlert = true
                }
            }
            .alert("Error de Registro", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(authViewModel.errorMessage ?? "Ocurrió un error desconocido.")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Valida que el formulario esté completo y las contraseñas coincidan.
    private var isFormValid: Bool {
        !fullname.isEmpty &&
        !email.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    // MARK: - Methods
    
    /// Acción que se ejecuta al presionar el botón de "Regístrate".
    private func signUp() {
        Task {
            await authViewModel.signUp(email: email, password: password, fullname: fullname)
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel(authService: FirebaseAuthenticationService()))
}
