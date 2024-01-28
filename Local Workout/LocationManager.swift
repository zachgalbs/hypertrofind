import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    private let locationManager = CLLocationManager()
    let searchCompleter = MKLocalSearchCompleter()
    @Published var region = MKCoordinateRegion()
    @Published var searchResults = [MKLocalSearchCompletion]()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        searchCompleter.delegate = self
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle error
    }
}
struct LocationView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardActive = false;
    @GestureState private var dragState = DragState.inactive
    @State private var positionOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                MapView(region: $locationManager.region)
                    .frame(height: geometry.size.height * 1.1)
                    .edgesIgnoringSafeArea(.top)
                VStack(alignment: .leading) {
                    VStack() {
                        RoundedRectangle(cornerRadius: 3)
                            .frame(width: 40, height: 6)
                            .foregroundColor(.secondary)
                            .padding(2)
                        TextField("Search", text: $searchText, onEditingChanged: { _ in
                            locationManager.searchCompleter.queryFragment = searchText
                        })
                        .padding(7)
                        .padding(.horizontal, 25)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                        locationManager.searchResults = []
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                        .padding(.horizontal, 10)
                        
                        List(locationManager.searchResults, id: \.self) { result in
                            Text(result.title).onTapGesture {
                                searchText = result.title
                                performSearch()
                                locationManager.searchResults = []
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(.top, 10)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .frame(height: 1000)
                    .offset(y: positionOffset + dragState.translation.height)
                    .gesture(
                        DragGesture()
                            .updating($dragState) { drag, state, transaction in
                                state = .dragging(translation: drag.translation)
                            }
                            .onEnded { 
                                drag in self.positionOffset += drag.translation.height
                            }
                    )
                }
                .edgesIgnoringSafeArea(.bottom)
                .position(x: geometry.size.width / 2, y: geometry.size.height - (keyboardActive ? geometry.size.height/2.4 : geometry.size.height * -0.1))
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                        let keyboardRectangle = keyboardFrame.cgRectValue
                        keyboardHeight = keyboardRectangle.height;
                        keyboardActive = true;
                        print(keyboardActive);
                    }
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0;
                    keyboardActive = false;
                }
            }
        }
    }

    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText

        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }

            if let firstItem = response.mapItems.first {
                let coordinate = firstItem.placemark.coordinate
                locationManager.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true // Show the user's location
        mapView.userTrackingMode = .follow // Follow the user's location
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
    }
}
enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
}

extension DragState {
    var isActive: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}
