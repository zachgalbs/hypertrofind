import SwiftUI
import MapKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class LocationManagerClass: NSObject, ObservableObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    var viewModel: SharedViewModel
    var locationManager: CLLocationManager!
    let searchCompleter = MKLocalSearchCompleter()
    @Published var region = MKCoordinateRegion()
    @Published var searchResults = [MKLocalSearchCompletion]()
    @Published var locationAnnotation = MKPointAnnotation()
    @Published var locationAnnotations: [MKPointAnnotation] = []

    init(viewModel: SharedViewModel) {
        self.viewModel = viewModel
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set the desired accuracy
        self.locationManager.requestWhenInUseAuthorization() // Request appropriate authorization from the user
        self.locationManager.startUpdatingLocation() // Start receiving location updates

        searchCompleter.delegate = self
        
        populatePredefinedLocations()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            viewModel.userLocation = location
            
            // If you want to center the map on the user's location
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.region = region // Assuming you want to update @Published var region to reflect this new region
            // Note: If you're using this region to update a map view in SwiftUI, ensure the view observes this @Published property and updates accordingly
        }
    }
    private func populatePredefinedLocations() {
        let locations = [
            ("Pardee Park", CLLocationCoordinate2D(latitude: 37.450013, longitude: -122.1422688)),
            ("Rinconada Park", CLLocationCoordinate2D(latitude: 37.444293, longitude: -122.142537)),
            ("YMCA", CLLocationCoordinate2D(latitude: 37.445697, longitude: -122.157272))
        ]

        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.title = location.0
            annotation.coordinate = location.1
            self.locationAnnotations.append(annotation)
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle error
    }
    // This function uses mapkit to search for fitness centers
    func searchForFitnessCenters() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "fitness centers"
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, _ in
            guard let self = self, let response = response else { return }
            DispatchQueue.main.async {
                self.locationAnnotations.removeAll() // Clear existing annotations
                for item in response.mapItems {
                    let annotation = MKPointAnnotation()
                    annotation.title = item.name
                    annotation.coordinate = item.placemark.coordinate
                    self.locationAnnotations.append(annotation)
                }
            }
        }
    }
}

struct LocationView: View {
    @ObservedObject var viewModel: SharedViewModel
    @State private var locationManager: LocationManagerClass
    @State private var searchText = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardActive = true;
    @GestureState private var dragState = DragState.inactive
    @State private var positionOffset: CGFloat = 0
    @State private var searching = true;
    @State private var shouldShowList = true;
    @State private var isWorkoutLogActive = false
    @State private var selectedWorkoutLog: WorkoutLog?
    @State private var possibleExercises: [String] = []
    @State private var isLocationConfirmed = false
    @State private var shouldConfirm = false

    init(viewModel: SharedViewModel) {
        self.locationManager = LocationManagerClass(viewModel: viewModel)
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                // THIS IS WHAT'S DISPLAYING THE MAP
                MapView(region: $locationManager.region, annotation: locationManager.locationAnnotation)
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
                        },
                        onCommit: {
                            performSearch()
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
                                if (!isLocationConfirmed && shouldConfirm) {
                                    
                                    Button(action: {
                                        viewModel.showWorkoutLog = true; // Update the shared view model
                                        viewModel.shouldGenerateExercises = true;
                                        isLocationConfirmed = true
                                    }) {
                                        Text("Confirm")
                                            .fontWeight(.bold) // Make the text bold
                                            .foregroundColor(.white) // Set text color to white
                                            .frame(minWidth: 0, maxWidth: .infinity) // Make the button take up the full available width
                                            .padding(.vertical, 10) // Increase padding vertically to make the button taller
                                    }
                                    .background(Color.blue) // Set the background color to blue
                                    .clipShape(RoundedRectangle(cornerRadius: 10)) // Round the corners of the button
                                    .padding(.trailing, 50) // Add some horizontal padding to the entire button, reducing its width a bit from the full screen width
                                    .shadow(color: .gray, radius: 5, x: 0, y: 5) // Optional: Add a shadow for a bit of depth
                                }
                            }
                        )
                        .padding(.horizontal, 10)
                        if shouldShowList {
                            List {
                                Section(header:  Text("Recommended Locations:")
                                .textCase(.none)
                                .bold()
                                .foregroundStyle(Color.white)
                                .font(.title3))
                                {
                                    ForEach(locationManager.locationAnnotations, id: \.self) { annotation in
                                        Text(annotation.title ?? "Unknown location")
                                            .onTapGesture {
                                                print((annotation.title ?? "") + " clicked!")
                                                searching = true
                                                shouldConfirm = true
                                                shouldShowList = false
                                                viewModel.currentLocation = annotation
                                                performSearch()
                                                locationManager.searchResults = []
                                            }
                                    }
                                }
                            }
                            .frame(height: 200)
                            .listRowBackground(Color(UIColor.systemGray6)) // Set background color for each row
                            .background(Color(UIColor.systemGray6))
                            .padding(.horizontal, 10)
                        }

                        List(locationManager.searchResults, id: \.self) { result in
                            Text("\(result.title), \(result.subtitle)").onTapGesture {
                                print (result)
                                searchText = result.title
                                searching = true;
                                shouldShowList = false;
                                performSearch()
                                locationManager.searchResults = []
                            }
                        }
                        .listRowBackground(Color(UIColor.systemGray6)) // Set background color for each row
                        .background(Color(UIColor.systemGray6))
                        .padding(.horizontal, 10)
                    }
                    .padding(.top, 10)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .offset(y: positionOffset + dragState.translation.height)
                    .position(
                        x: UIScreen.main.bounds.width/2,
                        // if the user is searching (they clicked on one of the locations) then the popup decreases in size and the user can see the map
                        y: searching ? 850 : UIScreen.main.bounds.height*0.5
                    )
                    .animation(.easeOut, value: keyboardActive) // Add animation for smooth transition
                    .animation(.easeOut, value: keyboardHeight) // Ensure the layout updates smoothly with keyboard height changes
                    .gesture(
                        DragGesture().updating($dragState, body: { (value, state, transaction) in
                            state = .dragging(translation: value.translation)
                        })
                        .onEnded({ (value) in
                            self.positionOffset += value.translation.height
                        })
                    )
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .onAppear {
                var firstTime = true;
                // once the keyboard is active,
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    // if the keyboardFrame is retrievable...
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                        let keyboardRectangle = keyboardFrame.cgRectValue
                        keyboardHeight = keyboardRectangle.height;
                        keyboardActive = true;
                        searching = false;
                        shouldShowList = true;
                        positionOffset = 0;
                    }
                }
                // if the user is no longer using the keyboard...
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    // this is here just because for some reason the popup doesn't trigger when the user presses the input section the first time
                    if (firstTime) {
                        keyboardHeight = 109;
                        keyboardActive = true;
                        searching = false;
                        positionOffset = 0;
                        shouldShowList = true;
                        firstTime = false;
                    }
                    else {
                        keyboardHeight = 0;
                        keyboardActive = false;
                        searching = true
                        shouldShowList = false;
                    }
                }
            }
        }
    }
    
    
    private func performSearch() {
        print("performSearch (user location: \(viewModel.userLocation)); id: \(viewModel.id)")
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText

        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard response == response else {
                return
            }
            print(viewModel.currentLocation?.title ?? "brother")
            if let firstItem = viewModel.currentLocation {
                print("First item: \(firstItem)")
                let searchCoordinate = firstItem.coordinate
                // Use the center of the current region as the user's location
                print(viewModel.userLocation?.coordinate ?? "Can't find")
                let userLocationCoordinate = viewModel.userLocation?.coordinate
                DispatchQueue.main.async {
                    self.locationManager.region = MKCoordinateRegion(center: userLocationCoordinate!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    // Update the annotation for the search result
                    self.locationManager.locationAnnotation.coordinate = searchCoordinate
                    self.locationManager.locationAnnotation.title = firstItem.title
                }
            } else {
                print("couldn't search")
            }
        }
    }

    private func regionThatFits(userLocation: CLLocationCoordinate2D, searchLocation: CLLocationCoordinate2D) -> MKCoordinateRegion {
        // Calculate the midpoint between the user's location and the search location
        print("user latitude: \(userLocation.latitude)")
        let midpointLatitude = (userLocation.latitude + searchLocation.latitude) / 2
        let midpointLongitude = (userLocation.longitude + searchLocation.longitude) / 2
        
        // Calculate the span directly from the differences in location, applying a small multiplier for slight padding
        let latitudeDelta = abs(userLocation.latitude - searchLocation.latitude) * 1.5 // 10% padding
        let longitudeDelta = abs(userLocation.longitude - searchLocation.longitude) * 1.5 // 10% padding
        
        // Create the coordinate span and region
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let midpoint = CLLocationCoordinate2D(latitude: midpointLatitude, longitude: midpointLongitude)
        return MKCoordinateRegion(center: midpoint, span: span)
    }




    func printContentsOfJSON() {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("JSON file not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let jsonDictionary = jsonObject as? [String: Any], // Check if it's a dictionary
               let exercises = jsonDictionary["exercises"] as? [[String: Any]] { // Access the "exercises" key
                // Now you have an array of exercise dictionaries
                for exercise in exercises {
                    if let name = exercise["name"] as? String {
                        print("Exercise Name: \(name)")
                        // You can similarly print other details if needed
                    }
                }
            }
        } catch {
            print("Error reading or parsing JSON file: \(error)")
        }
    }
}

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotation: MKPointAnnotation

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations) // Remove existing annotations
        uiView.addAnnotation(annotation) // Add new annotation
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
