import Foundation

func findWeeklyCompletedRoutines(routines: [CompletedRoutine]) -> [LiftData] {
    let today = Date()
    let calendar = Calendar.current
    var liftData = [LiftData]()
    
    // get the start of this week
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
