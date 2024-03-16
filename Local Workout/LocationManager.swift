import SwiftUI
import MapKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class LocationManagerClass: NSObject, ObservableObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    private let locationManager = CLLocationManager()
    let searchCompleter = MKLocalSearchCompleter()
    @Published var region = MKCoordinateRegion()
    @Published var searchResults = [MKLocalSearchCompletion]()
    @Published var locationAnnotation = MKPointAnnotation()
    @Published var locationAnnotations: [MKPointAnnotation] = []
    

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        searchCompleter.delegate = self
        
        populatePredefinedLocations()
    }
    private func populatePredefinedLocations() {
        let locations = [
            ("Pardee Park", CLLocationCoordinate2D(latitude: 37.444917, longitude: -122.145953)),
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

    func getLocation(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("brah");
        guard let location = locations.last else { return }
        region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
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
    @StateObject private var locationManager = LocationManagerClass()
    @State private var searchText = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardActive = true;
    @GestureState private var dragState = DragState.inactive
    @State private var positionOffset: CGFloat = 0
    @State private var searching = true;
    @State private var shouldShowList = true;
    @State private var isWorkoutLogActive = false
    @State private var selectedWorkoutLog: WorkoutLog?
    @State public var availableEquipment: [String] = []
    @State private var possibleExercises: [String] = []

    
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
                            // Call performSearch when the user hits return
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
                            }
                        )
                        .padding(.horizontal, 10)
                        if shouldShowList {
                            List {
                                Section(header:  Text("Recommended Locations:")
                                .textCase(.none)
                                .bold()
                                .foregroundStyle(Color.black)
                                .font(.title3))
                                {
                                    ForEach(locationManager.locationAnnotations, id: \.self) { annotation in
                                        Text(annotation.title ?? "Unknown location")
                                            .onTapGesture {
                                                print((annotation.title ?? "") + " clicked!")
                                                //printContentsOfJSON()
                                                
                                                givePossibleExercises(documentId: annotation.title ?? "master location")
                                                viewModel.showWorkoutLog = true; // Update the shared view model
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
                            Text(result.title).onTapGesture {
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
        print("performSearch")
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText

        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }

            if let firstItem = response.mapItems.first {
                let searchCoordinate = firstItem.placemark.coordinate
                // Use the center of the current region as the user's location
                let userLocation = self.locationManager.region.center
                print(userLocation)
                print(searchCoordinate)
                let region = self.regionThatFits(userLocation: userLocation, searchLocation: searchCoordinate)
                print(region)
                DispatchQueue.main.async {
                    self.locationManager.region = region
                    // Update the annotation for the search result
                    self.locationManager.locationAnnotation.coordinate = searchCoordinate
                    self.locationManager.locationAnnotation.title = firstItem.name ?? ""
                }
            }
        }
    }
    // Assuming this function is part of your SwiftUI view
    func fetchLocationDocument(documentId: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("locations").document(documentId.lowercased())

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let equipmentList = document.get("equipment") as? [String] {
                    DispatchQueue.main.async {
                        availableEquipment = equipmentList
                        completion()
                    }
                } else {
                    print("No equipment list found or it's not in the expected format.")
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    private func regionThatFits(userLocation: CLLocationCoordinate2D, searchLocation: CLLocationCoordinate2D) -> MKCoordinateRegion {
        print("regionThatFits run")
        // Calculate the midpoint between the user's location and the search location
        let midpointLatitude = (userLocation.latitude + searchLocation.latitude) / 2
        let midpointLongitude = (userLocation.longitude + searchLocation.longitude) / 2
        let midpoint = CLLocationCoordinate2D(latitude: midpointLatitude, longitude: midpointLongitude)

        // Calculate the deltas for latitude and longitude to create a span
        // Ensure the deltas are positive and increase them slightly to ensure both points are visible
        let latDelta = max(abs(userLocation.latitude - searchLocation.latitude), 0.01) * 2 // Ensure minimum delta to avoid too much zoom
        let longDelta = max(abs(userLocation.longitude - searchLocation.longitude), 0.01) * 2 // Ensure minimum delta to avoid too much zoom

        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)//MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
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
    struct Exercise: Decodable {
        let name: String
        let force: String?
        let level: String
        let mechanic: String?
        let equipment: String?
        let primaryMuscles: [String]
        let secondaryMuscles: [String]
        let instructions: [String]
        let category: String
    }

    struct ExerciseData: Decodable {
        let exercises: [Exercise]
    }
    // function to give possible exercises given a list of equipment
    func givePossibleExercises(documentId: String) {
        viewModel.shouldGenerateExercises = false
        print("running givePossibleExercises!")
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let exercisesData = try decoder.decode(ExerciseData.self, from: data)
            
            fetchLocationDocument(documentId: documentId) {
                // Process the filtered exercises
                let possibleExercises = exercisesData.exercises.filter { exercise in
                    guard let equipment = exercise.equipment else {
                        return false
                    }
                    if (self.availableEquipment.contains(equipment) || equipment == "other") && exercise.force == self.viewModel.split.lowercased() && (exercise.primaryMuscles.contains("chest") || exercise.primaryMuscles.contains("triceps") || exercise.primaryMuscles.contains("shoulders")) {
                        return true
                    } else {
                        return false
                    }
                }
                
                // Perform UI updates or modifications to `self` directly if needed, mindful of the execution context
                DispatchQueue.main.async {
                    self.viewModel.possibleExercises = possibleExercises
                    self.viewModel.shouldGenerateExercises = true
                }
            }
        } catch {
            print("Error decoding JSON: \(error)")
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
