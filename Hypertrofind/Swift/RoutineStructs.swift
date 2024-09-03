import Foundation

struct Routine: Codable, Hashable {
    var name: String
    var exercises: [RoutineExercise]
}

struct Exercise: Codable, Hashable{
    let name: String
    let force: String?
    let level: String
    let mechanic: String?
    let equipment: String
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let instructions: [String]
    let category: String
}

struct RoutineExercise: Codable, Hashable {
    var name: String
    var sets: [ExerciseSet]
    var muscles: [String]
    var instructions: [String]
    var equipment: String?
}

struct ExerciseSet: Codable, Hashable {
    var reps: Double
    var weight: Double
}

struct CompletedRoutine: Codable, Hashable {
    var routine: Routine
    var weight: Double
    var date: Date
    var day: String
}
