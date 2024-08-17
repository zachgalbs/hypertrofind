import Foundation

func findCompletedRoutines() -> [CompletedRoutine]? {
    if let completedRoutines: [CompletedRoutine] = loadJson(from: "completedRoutines.json") {
        // orders list from newest -> oldest
        let orderedRoutines = completedRoutines.sorted { $0.day > $1.day }
        return orderedRoutines
    } else {
        print("failed to load completed routines.")
        return nil
    }
}
func findWorkoutData() -> [LiftData] {
    let defaultWorkoutData: [LiftData] = [LiftData(day: "Mon", weight: 90), LiftData(day: "Tue", weight: 135)]
    var newWorkoutData = [LiftData]()
    if let completedRoutines = findCompletedRoutines() {
        if (completedRoutines.count >= 7) {
            for i in (1...6) {
                newWorkoutData.append(LiftData(day: completedRoutines[i].day, weight: completedRoutines[i].weight))
            }
            return newWorkoutData
        } else {
            for i in (0...(completedRoutines.count - 1)) {
                newWorkoutData.append(LiftData(day: completedRoutines[i].day, weight: completedRoutines[i].weight))
            }
            return newWorkoutData
        }
    } else {
        print("Couldn't get the first completed routine.")
        return defaultWorkoutData
    }
}

func findVolume() -> [LiftData] {
    if let completedRoutines = findCompletedRoutines() {
        let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var dailyWeights = [String: Double]()
        var liftData = [LiftData]()
        
        for day in daysOfWeek {
            var weight = 0.0
            for completedRoutine in completedRoutines {
                if completedRoutine.day == day {
                    weight += completedRoutine.weight
                }
            }
            dailyWeights[day] = weight
        }
        
        for day in daysOfWeek {
            if let weight = dailyWeights[day] {
                liftData.append(LiftData(day: day, weight: weight))
            }
        }
        
        return liftData
    }
    return []
}

func findAverageVolume(liftData: [LiftData]) -> Double {
    var numToDivide = 0.0
    for lift in liftData {
        numToDivide += lift.weight
    }
    return numToDivide/Double(liftData.count)
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
