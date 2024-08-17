import SwiftUI
import Foundation

// Exercise Model
struct Exercise: Codable, Identifiable {
    let name: String
    let force: String?
    let level: String
    let mechanic: String?
    let equipment: String?
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let instructions: [String]
    let category: String
    let images: [String]
    let id: String
}

// ViewModel for managing exercises
class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var exerciseNames: [String] = []
    init() {
        if let exercises: [Exercise] = loadJson(from: "exercises.json") {
            self.exercises = exercises
        }
        
    }
    
    func printExercises() {
        for exercise in exercises {
            print(exercise.name)
            exerciseNames.append(exercise.name)
        }
    }
}


struct RoutineBuilderView: View {
    @State private var name: String = ""
    @State private var exercises: [RoutineExercise] = [RoutineExercise(name: "", sets: 3, reps: 10, weight: 50)]
    @ObservedObject var viewModel = ExerciseViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(red: 0.2, green: 0.2, blue: 0.2)
                .edgesIgnoringSafeArea(.all)
            VStack {
                InputView(name: $name, exercises: $exercises, availableExercises: viewModel.exercises, exerciseNames: viewModel.exerciseNames)
                Spacer()
                HStack() {
                    Button(action: {
                        exercises.append(RoutineExercise(name: "", sets: 2, reps: 10, weight: 50))
                    }) {
                        Text("New Exercise")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .shadow(radius: 15)
                    }
                    Button(action: {
                        var routines: [Routine] = loadJson(from: "routines.json") ?? []
                        let routine = Routine(name: name, exercises: exercises)
                        routines.append(routine)
                        saveJson(data: routines, to: "routines.json")
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.vertical)
                            .padding(.horizontal, 50)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .shadow(radius: 15)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

// InputView to handle user input
struct InputView: View {
    @Binding var name: String
    @Binding var exercises: [RoutineExercise]
    var availableExercises: [Exercise]
    var exerciseNames: [String]
    @State var draggedOffset: CGFloat = 0
    @State private var indexToRemove: Int? = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.2)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack {
                        Text("Name")
                            .font(.title2)
                            .bold()
                        TextField("Name of routine", text: $name)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    }
                    List {
                        ForEach(exercises.indices, id: \.self) { index in
                            TextField("Enter exercise \(index + 1)", text: $exercises[index].name)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                        }
                        .onDelete(perform: delete)
                    }
                    .navigationTitle("New Routine")
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
}

#Preview {
    RoutineBuilderView()
}
