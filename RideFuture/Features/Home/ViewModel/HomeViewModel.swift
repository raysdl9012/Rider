//
//  HomeViewModel.swift
//  RideFuture
//
//  Gestión de estado de la pantalla principal:
//  - Ubicación del usuario (LocationManager)
//  - Región del mapa (zoom/cámara)
//  - Destino seleccionado
//  - Ruta generada entre usuario y destino
//  - Auto-recalcular ruta cuando el usuario se mueve
//

import Foundation
import MapKit
internal import Combine
internal import FirebaseFirestoreInternal



final class HomeViewModel: ObservableObject {
    
    @Published var region = MKCoordinateRegion()
    
    @Published var destination: MapDestinationEntity?
    @Published var route: MKRoute?
    @Published var tripEstimation: TripEstimation?
    
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        observeUserLocation()
    }
    
    var userLocation: CLLocation? {
        locationManager.location
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    /// Escucha actualizaciones del usuario y recalcula ruta si existe un destino
    private func observeUserLocation() {
        locationManager.$location
            .sink { [weak self] location in
                guard let self = self else { return }
                guard let location = location else { return }
                
                if self.destination == nil && self.route == nil {
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }
            .store(in: &cancellables)
    }
    
    func calculateRoute() {
        if let dest = self.destination {
            self.calculateRoute(to: dest.coordinate)
        }
    }
    
    /// Asigna destino y recalcula
    func setDestination(_ coordinate: CLLocationCoordinate2D, title: String) {
        destination = MapDestinationEntity(title: title, coordinate: coordinate)
        calculateRoute(to: coordinate)
    }
    
    /// Calcula la ruta desde user → destino
    private func calculateRoute(to dest: CLLocationCoordinate2D) {
        guard let userLoc = userLocation else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: .init(coordinate: userLoc.coordinate))
        request.destination = MKMapItem(placemark: .init(coordinate: dest))
        request.transportType = .automobile
        
        MKDirections(request: request).calculate { [weak self] response, error in
            guard let self = self else { return }
            guard let route = response?.routes.first else { return }
            
            DispatchQueue.main.async {
                self.route = route
                // Ajuste de zoom (sin animación)
                self.region = MKCoordinateRegion(fitting: route.polyline.boundingMapRect, padding: 0.7)
                let estimation = TripEstimation(
                    distanceInMeters: route.distance,
                    expectedTravelTime: route.expectedTravelTime
                )
                self.tripEstimation = estimation
            }
        }
    }
    
    func restoreActiveRide(activeRide: RideRequestEntity) async {
        let destination = MapDestinationEntity(
            title: activeRide.destinationTitle,
            coordinate: CLLocationCoordinate2D(
                latitude: activeRide.destinationLocation.latitude,
                longitude: activeRide.destinationLocation.longitude
            )
        )
        
        self.destination = destination
        calculateRoute()
    }
}
    
    
    
    
