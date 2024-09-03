import SwiftUI
import SwiftData

@main
struct HypertrofindApp: App {
    @State private var data = HypertrofindData()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(data)
        }
    }
}

@Observable class HypertrofindData {
    var routines: [Routine] = []
    var completedRoutines: [CompletedRoutine] = []
    var locations: [Location] = []
    var exercises: [Exercise] = []
    
    
    init() {
        loadRoutines()
        loadCompletedRoutines()
        loadLocations()
        loadExercises()
    }
    func loadExercises() {
        if let loadedExercises: [Exercise] = loadJson(from: "exercises") {
            self.exercises = loadedExercises
            print("got the exercises")
        } else {
            print("couldn't get the exercises")
        }
    }
    
    func loadLocations() {
        if let loadedLocations: [Location] = loadJson(from: "locations") {
            self.locations = loadedLocations
            print("Got the locations")
        } else {
            print("Couldn't get the locations")
        }
    }
    func loadCompletedRoutines() {
        if let loadedCompletedRoutines: [CompletedRoutine] = loadJson(from: "completedRoutines") {
            self.completedRoutines = loadedCompletedRoutines
            print("loaded completedRoutines")
        } else {
            print("couldn't load completedRoutines")
        }
    }
    func loadRoutines() {
        if let loadedRoutines: [Routine] = loadJson(from: "routines") {
            self.routines = loadedRoutines
            print("Loaded routines: \(routines)")
        } else {
            print("Failed to load routines.")
        }
    }
}
