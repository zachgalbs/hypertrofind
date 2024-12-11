import Foundation

func findWeeklyCompletedRoutines(routines: [CompletedRoutine]) -> [LiftData] {
    let today = Date()
    let calendar = Calendar.current
    var liftData = [LiftData]()
    
    // get the start of this week
    // should return the Monday of this week
    guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
        return []
    }
    
    // For each routine, check if it happened during this week, if it did, add it.
    for routine in routines {
        if routine.date > weekStart {
            liftData.append(LiftData(day: routine.day, weight: routine.weight))
        }
    }
    return liftData
}

func findAverageVolume(liftData: [LiftData]) -> Double {
    var totalWeight = 0.0
    var days: [String] = []
    for lift in liftData {
        totalWeight += lift.weight
        if !days.contains(lift.day) {
            days.append(lift.day)
        }
    }
    return totalWeight/Double(days.count)
}

func currentDayOfWeek() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E"
    return dateFormatter.string(from: Date())
}

func findMaxWeight(liftData: [LiftData]) -> Double {
    var largestWeight = 0.0
    for lift in liftData {
        if lift.weight > largestWeight {
            largestWeight = lift.weight
        }
    }
    return largestWeight
}

@Observable
class HypertrofindData {
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
        } else {
            print("Failed to load routines.")
        }
    }
}

@Observable
class ChartData {
    let workoutData: [LiftData]
    let averageWeight: Double
    let currentDay: String
    var maxWeight: Double
    
    init(completedRoutines: [CompletedRoutine]) {
        // Returns the routines completed from Monday to Sunday
        self.workoutData = findWeeklyCompletedRoutines(routines: completedRoutines)
        self.averageWeight = findAverageVolume(liftData: workoutData)
        self.currentDay = currentDayOfWeek()
        self.maxWeight = findMaxWeight(liftData: workoutData)
    }
}

// Define your data model. This is used to represent like each full workout you do (what day you did it on, and the total volume)
struct LiftData: Identifiable {
    let id = UUID()
    let day: String
    let weight: Double
}
