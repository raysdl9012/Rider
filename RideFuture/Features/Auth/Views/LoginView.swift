//
//  LoginView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI

/// Vista para que los usuarios existentes inicien sesión.
/// Se conecta al AuthViewModel a través de EnvironmentObject.
struct LoginView: View {
    
    // MARK: - Environment Objects
    
    /// Accede al ViewModel compartido desde la vista principal de la app.
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // MARK: - State Properties
    
    /// Almacena el email introducido por el usuario.
    @State private var email = ""
    /// Almacena la contraseña introducida por el usuario.
    @State private var password = ""
    /// Controla la presentación de la alerta de error.
    @State private var showingErrorAlert = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo degradado sutil para un look moderno.
                LinearGradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Logo o Título de la App
                    VStack(spacing: 8) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue.gradient)
                        Text("RideFuture")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 40)
                    
                    // Formulario de Inicio de Sesión
                    VStack(spacing: 20) {
                        AuthTextField(
                            text: $email,
                            title: "Email",
                            placeholder: "tu@email.com"
                        )
                        
                        AuthTextField(
                            text: $password,
                            title: "Contraseña",
                            placeholder: "Tu contraseña",
                            isSecureField: true
                        )
                        
                        // Botón de Iniciar Sesión
                        Button(action: signIn) {
                            Text("Iniciar Sesión")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 15))
                        }
                        .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                        .opacity(authViewModel.isLoading || email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Navegación a la vista de Registro
                    HStack {
                        Text("¿No tienes una cuenta?")
                            .foregroundColor(.secondary)
                        NavigationLink("Regístrate") {
                            SignUpView()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    }
                    .padding(.bottom, 20)
                }
                
                // Indicador de carga superpuesto
                if authViewModel.isLoading {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            .navigationBarTitleDisplayMode(.inline) // Oculta el título grande
            .toolbar {
                // Opcional: un botón de cerrar si se presenta como un sheet
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Button("Cerrar") { /* handle dismiss */ }
                    EmptyView()
                }
            }
            // Muestra una alerta si hay un mensaje de error en el ViewModel.
            .onChange(of: authViewModel.errorMessage) { errorMessage in
                if errorMessage != nil {
                    showingErrorAlert = true
                }
            }
            .alert("Error de Autenticación", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(authViewModel.errorMessage ?? "Ocurrió un error desconocido.")
            }
        }
    }
    
    // MARK: - Methods
    
    /// Acción que se ejecuta al presionar el botón de "Iniciar Sesión".
    /// Llama al método asíncrono del ViewModel.
    private func signIn() {
        Task {
            await authViewModel.signIn(email: email, password: password)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel(authService: FirebaseAuthenticationService()))
}
