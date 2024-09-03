import SwiftUI

struct InstructionView: View {
    @State var exercise: RoutineExercise
    @State var exerciseInstructions: [String] = []
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ScrollView {
            ZStack {
                Colors.shared.backgroundColor.ignoresSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {dismiss()}) {
                            Image(systemName: "x.circle.fill")
                                .font(.title)
                                .foregroundStyle(Color.gray)
                                .padding(.horizontal)
                        }
                    }
                    VStack {
                        HStack {
                            Text(exercise.name)
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(Color.white)
                                .padding(.horizontal)
                            Spacer()
                        }
                        Divider()
                            .background(Color.gray)
                            .padding(.horizontal)
                        HStack {
                            VStack {
                                Text("Primary muscles")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.gray)
                                ForEach(exercise.muscles, id: \.self) { muscle in
                                    Text(muscle)
                                }
                            }
                            Spacer()
                            VStack {
                                Text("Equipment")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.gray)
                                if let equipment = exercise.equipment {
                                   Text(equipment)
                                } else {
                                    Text("couldn't get the equipment type shit")
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        HStack {
                            Text("Instructions")
                                .font(.title)
                        }
                        .padding(.top, 20)
                        VStack {
                            ForEach(Array(exercise.instructions.enumerated()), id: \.element) { index, instruction in
                                HStack {
                                    Image(systemName: "\(index + 1).circle")
                                    Text(instruction)
                                }
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    .foregroundStyle(Color.white)
                    Spacer()
                }
            }
        }
        .background(Colors.shared.backgroundColor)
    }
}

#Preview {
    InstructionView(exercise: RoutineExercise(name: "Bench", sets: [ExerciseSet(reps: 10, weight: 100)], muscles: ["Chest"], instructions: ["nothing"], equipment: "bench"))
}
