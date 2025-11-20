import Foundation
internal import Combine

// El ViewModel ahora es agnóstico al proveedor de autenticación.
// Solo depende del protocolo, lo que lo hace 100% reutilizable y fácil de probar.

class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentUser: UserEntity?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    

    
    // MARK: - Initialization (Dependency Injection)
    
    init(authService: AuthenticationServiceProtocol) {
        self.authService = authService
        
        // Nos suscribimos al publisher del servicio de autenticación.
        // Cada vez que el estado del usuario cambie en el servicio,
        // esta suscripción se activará y actualizará las propiedades @Published.
        authService.currentUserPublisher
            .receive(on: DispatchQueue.main) // Asegura que la UI se actualice en el hilo principal
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = (user != nil)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods (Actions from the View)
    
    func signIn(email: String, password: String) async {
        await performOperation {
            try await self.authService.signIn(email: email, password: password)
        }
    }
    
    func signUp(email: String, password: String, fullname: String) async {
        await performOperation {
            try await self.authService.signUp(email: email, password: password, fullname: fullname)
        }
    }
    
    func signOut() {
        Task {
            await performOperation {
                try await self.authService.signOut()
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func performOperation(_ operation: @escaping () async throws -> Void) async {
        setLoading(true)
        do {
            try await operation()
            errorMessage = nil
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        setLoading(false)
    }
    
    private func setLoading(_ loading: Bool) {
        Task {
            await MainActor.run {
                isLoading = loading
            }
        }
    }
}
