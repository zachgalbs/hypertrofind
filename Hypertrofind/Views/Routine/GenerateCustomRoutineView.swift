//
//  GenerateCustomRoutineView.swift
//  Hypertrofind
//
//  Created by Zachary Galbraith on 8/17/24.
//

import SwiftUI

struct GenerateCustomRoutineView: View {
    @State var location: Location
    @State var routine: Routine
    var body: some View {
        ZStack {
            Color(red: 0.2, green: 0.2, blue: 0.2)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Loading your custom routine...")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundStyle(Color.white)
            }
        }
        .onAppear(perform: generateCustomRoutine)
    }
    private func generateCustomRoutine() {
        
    }
    private func getEquipmentExercises() {
        print("generating exercises for location: \(location.name)")
        var possibleExercises: [Exercise] = []
        if let exercises: [Exercise] = loadJson(from: "exercises.json") {
            print("got the exercises")
            for equipment in location.equipment {
                for exercise in exercises {
                    if equipment == exercise.equipment {
                        possibleExercises.append(exercise)
                    }
                }
            }
            print(possibleExercises.map { $0.name } )
        }
        else {
            print("failed")
        }
    }
//    private func getRoutineExercises() {
//        var possibleExercises: [Exercise] = []
//        if let exercises: [Exercise] = loadJson(from: "exercises.json") {
//            for exercise in exercises {
//               for 
//            }
//        }
//    }
}

#Preview {
    GenerateCustomRoutineView(location: Location(name: "example location", equipment: ["example equipment"]), routine: Routine(name: "", exercises: []))
}
