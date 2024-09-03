import SwiftUI

struct GenerateView: View {
    @State var location: Location
    @State var routine: Routine?
    @State var muscles: Set<String> = []
    @State var finalExercises: [RoutineExercise] = []
    @State private var isRoutineGenerated: Bool = false
    @Environment(HypertrofindData.self) var data
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.shared.backgroundColor
                    .ignoresSafeArea(.all)
                VStack {
                    if isRoutineGenerated {
                        Text("Your custom routine is ready!")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundStyle(Color.white)
                    } else {
                        Text("Loading your custom routine...")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundStyle(Color.white)
                    }
                }
                .navigationDestination(isPresented: $isRoutineGenerated) {
                    ActiveWorkoutView(routine: Routine(name: "Routine", exercises: finalExercises))
                        .navigationBarBackButtonHidden(true)
                }
            }
            .onAppear {
                Task {
                    await generateCustomRoutine()
                }
            }
        }
    }
    
    private func generateCustomRoutine() async {
        // gets all exercises that match equipment available and muscles selected
        var exercises = getExercisesBasedOnMuscles()
        // pick 5 specific exercises
        for _ in 0...5 {
            let randomInt = Int.random(in: 0...exercises.count - 1)
            finalExercises.append(exercises[randomInt])
            exercises.remove(at: randomInt)
        }
        
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 1 second delay
        isRoutineGenerated = true
    }
    
    private func getExercisesBasedOnMuscles() -> [RoutineExercise] {
        let exercises = getExercisesBasedOnEquipment()
        let exercisesTrainingMuscles = exercises.filter { exercise in
            !muscles.isDisjoint(with: exercise.primaryMuscles)
        }
        var routineExercisesTrainingMuscles: [RoutineExercise] = []
        
        for exercise in exercisesTrainingMuscles {
            let newExercise = RoutineExercise(name: exercise.name, sets: [ExerciseSet(reps: 10, weight: 100)], muscles: exercise.primaryMuscles, instructions: exercise.instructions, equipment: exercise.equipment)
            routineExercisesTrainingMuscles.append(newExercise)
        }
        return routineExercisesTrainingMuscles
    }
    
    private func getExercisesBasedOnEquipment() -> [Exercise] {
        print("Generating exercises for \(location.name)")
        let exercises = data.exercises
        return exercises.filter { exercise in
            location.equipment.contains(exercise.equipment) || exercise.equipment == "body only"
        }
    }
}

#Preview {
    GenerateView(location: Location(name: "example location", equipment: ["example equipment"]))
}
