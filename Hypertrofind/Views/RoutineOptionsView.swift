//
//  SetOptionsView.swift
//  Hypertrofind
//
//  Created by Zachary Galbraith on 8/10/24.
//

import SwiftUI

struct RoutineOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @State var routine: Routine
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.12).edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "x.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.gray)
                            .padding()
                    }
                }
                Spacer()
                Button(action: {
                    print("something")
                    deleteRoutine()
                    dismiss()
                }) {
                    HStack {
                        Text("Delete")
                            .foregroundStyle(Color.red)
                        Spacer()
                        Image(systemName: "trash")
                            .foregroundStyle(Color.red)
                    }
                    .padding()
                }
                .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                .frame(width: 350)
                .clipShape(.buttonBorder)
            }
        }
    }
    private func deleteRoutine() {
        print("deleted!")
        if var routines: [Routine] = loadJson(from: "routines.json") {
            routines.removeAll { $0.hashValue == routine.hashValue }
            saveJson(data: routines, to: "routines.json")
        } else {
            print("couldn't load json")
        }
    }
}
