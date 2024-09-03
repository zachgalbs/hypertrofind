import SwiftUI
import Foundation

struct RoutineBuilderView: View {
    @State private var name: String = ""
    @State private var exercises: [RoutineExercise] = []
    @Environment(\.dismiss) var dismiss
    @Environment(HypertrofindData.self) var data
    
    var body: some View {
        ZStack {
            Colors.shared.backgroundColor
                .ignoresSafeArea(.all)
            VStack {
                InputView(name: $name, exercises: $exercises, availableExercises: data.exercises)
                Spacer()
                HStack() {
                    Button(action: {
                        let routine = Routine(name: name, exercises: exercises)
                        data.routines.append(routine)
                        saveJson(data: data.routines, to: "routines")
                        dismiss()
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
private struct InputView: View {
    @Binding var name: String
    @Binding var exercises: [RoutineExercise]
    var availableExercises: [Exercise]
    @State var draggedOffset: CGFloat = 0
    @State private var indexToRemove: Int? = 0
    @State private var showSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.shared.backgroundColor
                    .ignoresSafeArea(.all)
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
                    VStack {
                        HStack {
                            Text("Exercises")
                                .bold()
                                .font(.title2)
                            Spacer()
                            Button(action: {
                                showSheet.toggle()
                            }) {
                                Image(systemName: "plus.app")
                                    .font(.title2)
                            }
                        }
                        List {
                            ForEach(exercises, id: \.self) { exercise in
                                Text(exercise.name)
                            }
                            .onDelete(perform: delete)
                        }
                        .navigationTitle("New Routine")
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showSheet, content: {
            SheetView(selectedExercises: $exercises)
        })
    }
    
    func delete(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
}
struct SheetView: View {
    @State private var searchText: String = ""
    @Environment(\.dismiss) var dismiss
    @Environment(HypertrofindData.self) var data
    @Binding var selectedExercises: [RoutineExercise]
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredExercises, id: \.self) { exercise in
                    Button(action: {
                        selectedExercises.append(makeRoutineExercise(exercise: exercise))
                        dismiss()
                    }) {
                        Text(exercise.name)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search")
    }
    private var filteredExercises: [Exercise] {
        if (searchText.isEmpty) {
            return data.exercises
        } else {
            return data.exercises.filter {$0.name.localizedCaseInsensitiveContains(searchText)}
        }
    }
    private func makeRoutineExercise(exercise: Exercise) -> RoutineExercise {
        let name = exercise.name
        let sets = [ExerciseSet(reps: 10, weight: 100)]
        let muscles = exercise.primaryMuscles
        let instructions = exercise.instructions
        let equipment = exercise.equipment
        return RoutineExercise(name: name, sets: sets, muscles: muscles, instructions: instructions, equipment: equipment)
    }
}

#Preview {
    RoutineBuilderView()
}
