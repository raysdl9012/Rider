import SwiftUI
import MapKit

/// La vista principal de la aplicación después del inicio de sesión.
/// Muestra un mapa, permite buscar destinos y muestra un marcador en el mapa.
struct HomeView: View {
    
    // MARK: - State Objects & State Properties
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var rideRequestViewModel: RideRequestViewModel
    /// Controla la presentación de la hoja de búsqueda.
    @State private var isShowingSearch = false
    @State private var isShowingPaymentView = false
    
    @State private var rideForPayment: RideRequestEntity?
    @State private var priceForPayment: Double?
    
    
    init() {
        let rideService = FirebaseRideRequestService()
        let authModel = AuthViewModel(authService: FirebaseAuthenticationService())
        _rideRequestViewModel = StateObject(wrappedValue: RideRequestViewModel(rideRequestService: rideService, authViewModel: authModel))
    }
    
    private var annotation: [MapDestinationEntity]  {
        if let destination = viewModel.destination {
            return [destination]
        }else {
            return []
        }
        
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    userTrackingMode: .none,
                    annotationItems: viewModel.destination.map { [$0] } ?? []) { marker in
                    
                    MapAnnotation(coordinate: marker.coordinate) {
                        DestinationPinView(title: marker.title)
                    }
                    
                }
                    .ignoresSafeArea()
                
                RouteMapView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                
                
                // UI flotante superpuesta en la parte inferior.
                VStack(spacing: 15) {
                    
                    if let rideRequest = rideRequestViewModel.currentRideRequest {
                        RideStatusView(rideRequest: rideRequest) {
                            Task {
                                await rideRequestViewModel.simulateCancellation()
                            }
                        }
                        .transition(.move(edge: .top)
                            .combined(with: .opacity))
                    }
                    
                    
                    if let estimation = viewModel.tripEstimation {
                        let price = PricingService().calculatePrice(for: estimation)
                        TripEstimationView(estimation: estimation, price: price)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    if rideRequestViewModel.currentRideRequest != nil {
                        RideSimulationPanel(rideRequestViewModel: rideRequestViewModel)
                            .padding(.horizontal, 30)
                    }else {
                        ControlView(isShowingSearch: $isShowingSearch,
                                    destination: $viewModel.destination) {
                            
                            if let destination = viewModel.destination,
                               let userLocation = viewModel.userLocation{
                                rideRequestViewModel.requestRide(pickup: userLocation.coordinate,
                                                                 destination: destination)
                            }
                        }
                    }
                    
                }
            }
            .sheet(isPresented: $isShowingSearch) {
                DestinationSearchView(selectedDestination: $viewModel.destination)
            }
            .alert("Error", isPresented: .constant(rideRequestViewModel.errorMessage != nil)) {
                Button("OK") {
                    rideRequestViewModel.errorMessage = nil
                }
            } message: {
                Text(rideRequestViewModel.errorMessage ?? "Error desconocido")
            }
            .onAppear {
                viewModel.requestLocation()
            }
            .onChange(of: viewModel.destination) { newDestination in
                guard let newDestination else { return }
                viewModel.destination = newDestination
                viewModel.calculateRoute()
            }
            
            .onReceive(rideRequestViewModel.rideFinishedPublisher) { _ in
                resetUIState()
            }
            .task {
                if let userId = authViewModel.currentUser?.id {
                    guard let activeRide = await rideRequestViewModel.restoreActiveRide(for: userId) else {
                        return
                    }
                    await viewModel.restoreActiveRide(activeRide: activeRide)
                }
            }
            .toolbar {
                // *** NUEVO ***: Botón en la barra de navegación para acceder al historial.
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: TripHistoryView()) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingPaymentView) {
                if let ride = rideForPayment, let price = priceForPayment {
                    PaymentView(rideRequest: ride, finalPrice: price)
                }
            }
            .onChange(of: rideRequestViewModel.currentRideRequest?.status) { status in
                // Si el viaje se completa, mostramos la vista de pago.
                guard let newStatus = status else { return }
                if newStatus == .completed {
                    if let ride = rideRequestViewModel.currentRideRequest,
                       let estimation = viewModel.tripEstimation {
                        let finalPrice = PricingService().calculatePrice(for: estimation)
                        self.rideForPayment = ride
                        self.priceForPayment = finalPrice
                        
                        // Ahora que tenemos los datos, mostramos la vista.
                        self.isShowingPaymentView = true
                    }
                }
                
                // Si el viaje se cancela, nos aseguramos de que la vista de pago no se muestre.
                if status == .cancelled {
                    isShowingPaymentView = false
                    rideForPayment = nil
                    priceForPayment = nil
                }
            }
        }
        
    }
}

extension HomeView {
    
    private func updateRequestRIDE() {
        if let destination = viewModel.destination,
           let userLocation = viewModel.userLocation {
            rideRequestViewModel.requestRide(pickup: userLocation.coordinate,
                                             
                                             destination: destination)
        }
    }
    private func resetUIState() {
        withAnimation(.easeInOut) {
            DispatchQueue.main.async {
                viewModel.destination = nil
                viewModel.route = nil
                viewModel.tripEstimation = nil
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel(authService: FirebaseAuthenticationService()))
}
