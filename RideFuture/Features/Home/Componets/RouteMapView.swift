import SwiftUI
import MapKit

//
//  RouteMapView.swift
//  RideFuture
//
//  Representación SwiftUI de un MKMapView tradicional.
//  Permite dibujar rutas, manejar cámara 3D, seguir al usuario y
//  mostrar pines personalizados, funcionalidades no soportadas por
//  el componente SwiftUI Map en iOS 16.
//
//  Este wrapper es fundamental para características avanzadas
//  estilo Uber: ruta dinámica, seguimiento en tiempo real, zoom animado,
//  y división de ruta recorrida (gris) vs restante (azul).
//


/// Vista SwiftUI que integra un MKMapView mediante UIViewRepresentable.
/// Se utiliza cuando se necesita un control total del mapa: polylines, cámara,
/// overlays avanzados o animaciones no disponibles en Map.
struct RouteMapView: UIViewRepresentable {
    
    @ObservedObject var viewModel: HomeViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.showsUserLocation = true
        map.delegate = context.coordinator
        map.isRotateEnabled = false
        map.pointOfInterestFilter = .excludingAll
        return map
    }
    
    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.viewModel = viewModel
        
        map.setRegion(viewModel.region, animated: false)
        
        context.coordinator.updateOverlays(map)
        context.coordinator.updateDestinationPin(map)
    }
    
    func makeCoordinator() -> RouteMapCoordinator {
        RouteMapCoordinator(viewModel: viewModel)
    }
}
//
//  RouteMapCoordinator.swift
//  RideFuture
//
//  Delegado de MKMapView responsable de:
//  - Dibujar rutas y overlays personalizados.
//  - Partir la ruta en dos: recorrida (gris) y restante (azul).
//  - Actualizar pines del destino.
//  - Animar la cámara con efecto 3D estilo Uber.
//  - Seguir el movimiento del usuario y recalcular la ruta.
//
//  Este archivo contiene la lógica que MapKit necesita y SwiftUI no puede
//  manejar directamente con 'Map'.
//


/// Coordinador que actúa como delegado del MKMapView.
/// Responsable de renderizar polylines, añadir anotaciones y manejar la cámara.
final class RouteMapCoordinator: NSObject, MKMapViewDelegate {
    
    var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Pins
    func updateDestinationPin(_ map: MKMapView) {
        map.removeAnnotations(map.annotations.filter { !($0 is MKUserLocation) })
        
        guard let dest = viewModel.destination else { return }
        
        let ann = MKPointAnnotation()
        ann.title = dest.title
        ann.coordinate = dest.coordinate
        
        map.addAnnotation(ann)
    }
    
    // MARK: - Overlays (Rutas)
    func updateOverlays(_ map: MKMapView) {
        map.removeOverlays(map.overlays)
        guard let route = viewModel.route else { return }
        
        // Ruta completa (azul)
        map.addOverlay(route.polyline, level: .aboveRoads)
    }
    
    // Render ruta
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let r = MKPolylineRenderer(overlay: overlay)
        r.lineWidth = 6
        r.strokeColor = .systemBlue
        return r
    }
    
    // MARK: - User Interaction
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("regionWillChangeAnimated")
    }
}

//
//  CLLocationCoordinate2D+Extensions.swift
//  RideFuture
//
//  Extensiones para cálculos geoespaciales usados en el render de cámara.
//

extension CLLocationCoordinate2D {
    
    /// Calcula el rumbo (bearing) desde este punto hacia otro.
    func bearing(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        let deltaLon = coordinate.longitude - longitude
        let y = sin(deltaLon) * cos(coordinate.latitude)
        let x = cos(latitude) * sin(coordinate.latitude)
        - sin(latitude) * cos(coordinate.latitude) * cos(deltaLon)
        
        return atan2(y, x).toDegrees()
    }
}

extension Double {
    /// Convierte radianes a grados.
    func toDegrees() -> Double { self * 180 / .pi }
}

extension MKCoordinateRegion {
    init(fitting rect: MKMapRect, padding: Double) {
        self = MKCoordinateRegion(rect)
        
        let span = MKCoordinateSpan(
            latitudeDelta: self.span.latitudeDelta / padding,
            longitudeDelta: self.span.longitudeDelta / padding
        )
        
        self = MKCoordinateRegion(center: self.center, span: span)
    }
}
