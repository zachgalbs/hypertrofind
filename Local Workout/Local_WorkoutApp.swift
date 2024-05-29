import SwiftUI
import MapKit
import Firebase
import FirebaseAuth

@main
struct Local_WorkoutApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var sharedViewModel = SharedViewModel()
    //var locationManager: LocationManagerClass
    
    init() {
        // Configure the appearance of UI components
        UITabBar.appearance().backgroundColor = UIColor.systemGray
        // Configure Firebase
        if FirebaseApp.app() == nil { // Ensure Firebase is not configured more than once
            FirebaseApp.configure()
        }
        //self.setupAuthenticationListener()
        
        //self.sharedViewModel = SharedViewModel()
        //self.locationManager = LocationManagerClass(viewModel: sharedViewModel)
    }

    var body: some Scene {
        WindowGroup {
            if Auth.auth().currentUser != nil {
                authenticatedView
            } else {
                SignUpView
            }
        }
    }
    public var SignUpView: some View {
        SignUpPage(viewModel: sharedViewModel)
    }
    public var authenticatedView: some View {
        TabView(selection: $sharedViewModel.selectedTab) {
            Home(viewModel: sharedViewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(AppTab.statistics)
            
            WorkoutLog(viewModel: sharedViewModel)
                .tabItem {
                    Label("Routines", systemImage: "figure.strengthtraining.traditional").foregroundColor(.blue) // Corrected usage
                }
                .tag(AppTab.routines)
            
            LocationView(viewModel: sharedViewModel)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(AppTab.map)
            ProfilePage(viewModel: sharedViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(AppTab.profile)
        }
    }

    private func setupAuthenticationListener() {
        Auth.auth().addStateDidChangeListener { auth, user in
            DispatchQueue.main.async {
                self.sharedViewModel.isUserAuthenticated = (user != nil)
                print("Authentication state changed: \(self.sharedViewModel.isUserAuthenticated )")
            }
        }
    }
}

enum AppTab: Hashable {
    case statistics, routines, map, profile
}

class SharedViewModel: ObservableObject {
    let id = UUID()
    
    @Published var selectedTab: AppTab = .statistics
    @Published var shouldGenerateExercises: Bool = false
    @Published var showWorkoutLog: Bool = false {
        didSet {
            if showWorkoutLog {
                selectedTab = .routines // Change to the WorkoutLog tab when showWorkoutLog is true
            }
        }
    }
    @Published var showInstructionView: Bool = false
    @Published var muscleGroup: String = "Push"
    @Published var split: String = "Push Pull Legs"
    @Published var day: String = "Monday"
    @Published var currentInstructions: String?
    @Published var isUserAuthenticated: Bool = false
    @Published var username: String = "null"
    @Published var userLocation: CLLocation?
    @Published var currentLocation: MKPointAnnotation?
    private var firestoreManager = FirestoreManager()

    init() {
        firestoreManager.fetchData()
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

class FirestoreManager: ObservableObject {
    private var db = Firestore.firestore()
    
    func fetchData() {
        db.collection("locations").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for _ in querySnapshot!.documents {
                    //print("DOCUMENT DATA: \(document.documentID) => \(document.data())")
                }
            }
        }
    }
}

// Ensure that LocationView and its Exercise type, and other custom views like Home, WorkoutLog, InstructionsView are correctly defined elsewhere in your project.
