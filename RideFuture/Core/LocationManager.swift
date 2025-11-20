//
//  LocationManager.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import Foundation
import CoreLocation
internal import Combine

/// Gestor de ubicación simple y desacoplado.
/// Solo se encarga de publicar ubicaciones, sin lógica de rutas.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published Properties
    
    /// Última ubicación del usuario.
    @Published var location: CLLocation?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    /// Configura CLLocationManager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Pedir permisos
        locationManager.requestWhenInUseAuthorization()
        
        // Obtener ubicación inicial
        locationManager.requestLocation()
        
        // Escuchar movimientos continuos
        locationManager.startUpdatingLocation()
        // Calcular distancia cada metro
        locationManager.distanceFilter = 1
        
    }
    
    // MARK: - Public Methods
    
    /// Solicita una actualización puntual de ubicación
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager failed with error: \(error.localizedDescription)")
        
        // Si el usuario denegó los permisos, detener actualizaciones
        if let clError = error as? CLError, clError.code == .denied {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
            
        case .denied, .restricted:
            locationManager.stopUpdatingLocation()
            
        default:
            break
        }
    }
}

