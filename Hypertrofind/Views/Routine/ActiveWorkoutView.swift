//
//  ActiveWorkoutPage.swift
//  Hypertrofind
//
//  Created by Zachary Galbraith on 8/5/24.
//

import SwiftUI

struct ActiveWorkoutView: View {
    var routine: Routine
    
    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    Text(routine.name)
                        .font(.system(size: 50))
                        .bold()
                        .padding(.top)
                        .foregroundStyle(Color.white)
                    Spacer()
                }
                VStack {
                    Spacer()
                    ForEach(routine.exercises, id: \.self) { exercise in
                        ExerciseView(exercise: exercise)
                    }
                    Spacer()
                    FinishButton(routine: routine)
                }
            }
        }
    }
}

struct ExerciseView: View {
    @State var exercise: RoutineExercise
    @State private var isEllipsisPressed = false
    @State private var isQuestionPressed = false
    @State var deleteSet = false
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(exercise.name)
                            .font(.system(size: 30))
                            .bold()
                            .foregroundStyle(Color.secondaryElement)
                        Spacer()
                        Button(action: {
                            isQuestionPressed.toggle()
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                        }
                    }
                    .sheet(isPresented: $isQuestionPressed) {
                        InstructionView(exercise: exercise)
                            .presentationDetents([.fraction(0.99), .large])
                    }
                    
                    ForEach(Array(exercise.sets.enumerated()), id: \.element) { index, set in
                        HStack(alignment: .bottom) {
                            Image(systemName: "\(index + 1).circle")
                                .font(.title)
                            HStack(spacing: 15) {
                                VStack {
                                    Text("lbs")
                                        .font(.caption)
                                        .foregroundStyle(Color.gray)
                                    TextField("routine.exercise", value: $exercise.sets[index].weight, formatter: NumberFormatter())
                                        .keyboardType(.numberPad)
                                        .frame(width: 30)
                                        .padding(.top, -8)
                                }
                                VStack {
                                    Text("reps")
                                        .font(.caption)
                                        .foregroundStyle(Color.gray)
                                    TextField("routine.exercise", value: $exercise.sets[index].weight, formatter: NumberFormatter())
                                        .keyboardType(.numberPad)
                                        .frame(width: 30)
                                        .padding(.top, -8)
                                }
                            }
                            Spacer()
                            VStack {
                                Button(action: {
                                    isEllipsisPressed.toggle()
                                }) {
                                    Image(systemName: "ellipsis")
                                        .frame(maxHeight: .infinity)
                                }
                                .sheet(isPresented: $isEllipsisPressed) {
                                    SetOptionsView(sets: $exercise.sets, index: index)
                                        .presentationDetents([.medium, .large])
                                }
                            }
                        }
                        Divider()
                            .background(Color.white)
                    }
                    HStack {
                        Button(action: {
                            exercise.sets.append(ExerciseSet(reps: 10, weight: 100))
                        }) {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .padding(.top)
                        }
                    }
                }
                .padding()
                Spacer()
            }
        }
        .frame(width: 350)
        .background(Color.tertiaryElement)
        .foregroundStyle(Color.white)
        .clipShape(.rect(cornerRadius: 10))
        .padding()
    }
}


struct FinishButton: View {
    var routine: Routine
    @Environment(\.dismiss) var dismiss
    @Environment(HypertrofindData.self) var data
    
    var body: some View {
        Button(action: finishWorkout) {
            Text("Finish Workout")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 15)
                .padding(.horizontal, 30)
                .background(
                    LinearGradient(
                        colors: [Color.black, Color.gray],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 5, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white, lineWidth: 2)
                )
        }
        .padding()
    }
    
    private func finishWorkout() {
        var completedRoutines = data.completedRoutines
        var totalWeight = 0.0
        for exercise in routine.exercises {
            print("exercise: \(exercise.name)")
            for exerciseSet in exercise.sets {
                totalWeight += exerciseSet.weight
            }
        }
        let day = findDay(currentDate: Date())
        let completedRoutine = CompletedRoutine(routine: routine, weight: totalWeight, date: Date(), day: day)
        completedRoutines.append(completedRoutine)
        saveJson(data: completedRoutines, to: "completedRoutines")
        dismiss()
    }
    private func findDay(currentDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"  // "EEEE" gives the full name of the day (e.g., "Monday")
        
        let dayOfWeek = dateFormatter.string(from: currentDate)
        return dayOfWeek
    }
}

extension Color {
    static let specialElement = Color(red: 0.89, green: 0.72, blue: 0.08)
    static let secondaryElement = Color(red: 0.82, green: 0.82, blue: 0.77)
    static let tertiaryElement = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let background = Color.black
}

#Preview {
    ActiveWorkoutView(routine: Routine(name: "Push", exercises: [RoutineExercise(name: "Bench Press", sets: [ExerciseSet(reps: 10, weight: 100)], muscles: [], instructions: ["brother"])]))
}
