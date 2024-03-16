import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore
//import FirebaseAuth

@main
struct Local_WorkoutApp: App {
    @StateObject private var sharedViewModel = SharedViewModel() // Shared view model instance

    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemGray
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $sharedViewModel.selectedTab) {
                Home(viewModel: sharedViewModel)
                    .tabItem {
                        Label("Statistics", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(AppTab.statistics)
                
                WorkoutLog(viewModel: sharedViewModel)
                    .tabItem {
                        Label("Routines", systemImage: "figure.strengthtraining.traditional")
                    }
                    .foregroundColor(.blue) // This may not work as expected; `foregroundColor` should be applied to the Label instead
                    .tag(AppTab.routines)
                
                LocationView(viewModel: sharedViewModel)
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(AppTab.map)
                InstructionsView(viewModel: sharedViewModel)
                    .tabItem {
                        Label("Instructions", systemImage: "circle.fill")
                    }
                    .tag(AppTab.instruction)
            }
        }
    }
}
enum AppTab {
    case statistics, routines, map, instruction
}

class SharedViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .statistics
    @Published var shouldGenerateExercises: Bool = false
    @Published var showWorkoutLog: Bool = false {
        didSet {
            if showWorkoutLog {
                selectedTab = .routines // Change to the WorkoutLog tab when showWorkoutLog is true
            }
        }
    }
    @Published var showInstructionView: Bool = false {
        didSet {
            if showInstructionView {
                selectedTab = .instruction
            }
        }
    }
    @Published var split: String = "Push"
    @Published var possibleExercises: [LocationView.Exercise] = []
    @Published var currentInstructions: String?
    private var firestoreManager = FirestoreManager()

    init() {
        firestoreManager.fetchData()
    }
}

class FirestoreManager: ObservableObject {
    private var db = Firestore.firestore()
    
    func fetchData() {
        db.collection("locations").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("DOCUMENT DATA: \(document.documentID) => \(document.data())")
                }
            }
        }
    }
}

struct Location: Identifiable {
    var id: String
    var name: String
    // Add other properties as needed
}
