import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0302),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var locationViewOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isSearchBarActive = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map {
                    if let userLocation = locationManager.lastLocation {
                        Marker("Random Location", coordinate: userLocation.coordinate)
                        Annotation("Random Annotation", coordinate: CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.1302)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.yellow)
                                Text("😁")
                                    .padding(5)
                            }
                        }
                    }
                }
                .onAppear {
                    locationManager.requestLocation()
                }
                .onChange(of: locationManager.lastLocation) { oldLocation, newLocation in
                    if let location = newLocation {
                        region = MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    }
                }
                .mapControlVisibility(.hidden)
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        LocationView(isSearchBarActive: $isSearchBarActive)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            // the great the offset, the lower the LocationView
                            .offset(y: max(0, locationViewOffset + dragOffset))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        // Allow dragging up and down without constraints
                                        dragOffset = value.translation.height
                                    }
                                    .onEnded { value in
                                        let snapPosition = geometry.size.height * 0.3
                                        // if the LocationView's difference between it's normal position and the length of the drag are greater than 3/4's of the screen's height, set the position of the LocationView to 1/2 of the screen's height.
                                        if locationViewOffset + dragOffset > snapPosition {
                                            locationViewOffset = geometry.size.height * 0.6
                                        } else {
                                            locationViewOffset = 0
                                        }
                                        
                                        dragOffset = 0
                                    }
                            )
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            locationViewOffset = geometry.size.height * 0.6
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error w the location: \(error.localizedDescription)")
    }
}

#Preview {
    MapView()
}
