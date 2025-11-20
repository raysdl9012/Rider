//
//  AuthenticationServiceProtocol.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
internal import Combine

// Define el "contrato" para cualquier servicio de autenticación.
// Ni el ViewModel ni las vistas saben si la implementación es Firebase, Auth0, etc.
protocol AuthenticationServiceProtocol {
    
    /// Un publicador que emite el usuario actual o nil si no hay sesión.
    /// Usamos `AnyPublisher` para ocultar los detalles de implementación de Combine.
    var currentUserPublisher: AnyPublisher<UserEntity?, Never> { get }
    /// Inicia sesión con email y contraseña.
    func signIn(email: String, password: String) async throws
    /// Registra un nuevo usuario con email, contraseña y nombre completo.
    func signUp(email: String, password: String, fullname: String) async throws
    /// Cierra la sesión del usuario actual.
    func signOut() async throws
}

// Esta es la implementación CONCRETA que utiliza Firebase.
// Es el único archivo en tu proyecto que debería importar FirebaseAuth.
class FirebaseAuthenticationService: AuthenticationServiceProtocol {
    
    // MARK: - Properties
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    // Usamos un CurrentValueSubject para emitir el estado actual del usuario.
    private var currentUserSubject = CurrentValueSubject<UserEntity?, Never>(nil)
    
    var currentUserPublisher: AnyPublisher<UserEntity?, Never> {
        // Exponemos el subject como un AnyPublisher para que el exterior no pueda modificarlo.
        currentUserSubject.eraseToAnyPublisher()
    }
    
    private var handle: AuthStateDidChangeListenerHandle?
    var rideRequestViewModel: RideRequestViewModel?
    // MARK: - Initialization
    
    init() {
        // El listener de Firebase ahora actualiza nuestro Subject de Combine.
        handle = auth.addStateDidChangeListener { [weak self] _, user in
            self?.currentUserSubject.send(self?.mapFirebaseUser(user))
        }
    }
    
    // MARK: - Protocol Conformance
    
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
        // El listener `addStateDidChangeListener` se encargará de actualizar el publisher.
    }
    
    func signUp(email: String, password: String, fullname: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        let user = result.user
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = fullname
        try await changeRequest.commitChanges()
        // Guardar datos adicionales en Firestore
        try await db.collection(FIR_COLLECTION_USERS).document(user.uid).setData([
            "fullname": fullname,
            "email": email,
            "createdAt": Timestamp(date: Date())
        ])
    }
    
    func signOut() async throws {
        try auth.signOut()
        // El listener `addStateDidChangeListener` se encargará de actualizar el publisher.
    }
    
    // MARK: - Helpers
    
    /// Función de ayuda para mapear un objeto de Firebase a nuestro modelo de User.
    private func mapFirebaseUser(_ firebaseUser: FirebaseAuth.User?) -> UserEntity? {
        guard let firebaseUser = firebaseUser else { return nil }
        return UserEntity(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            fullname: firebaseUser.displayName ?? "Usuario"
        )
    }
    
    deinit {
        if let handle = handle {
            auth.removeStateDidChangeListener(handle)
        }
    }
}
