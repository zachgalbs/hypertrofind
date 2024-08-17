import Foundation

struct Routine: Codable, Hashable {
    var name: String
    var exercises: [RoutineExercise]
}

struct RoutineExercise: Codable, Hashable {
    var name: String
    var sets: Int
    var reps: Double
    var weight: Double
}

struct CompletedRoutine: Codable, Hashable {
    var routine: Routine
    var weight: Double
    var date: Date
    var day: String
}
