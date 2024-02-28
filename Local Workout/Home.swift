//
//  ContentView.swift
//  Local Workout
//
//  Created by Zachary on 11/13/23.
//
import Foundation
import SwiftUI

struct Home: View {
    @ObservedObject var viewModel: SharedViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Hypertrofind").font(.largeTitle)
                .bold()
                .foregroundColor(Color.white)
                .padding(.leading, -20)
            Text("Activity: ").font(.title)
                .foregroundColor(Color.white)
                .padding(.leading, -10)
            Text("Total days: 10")
                .foregroundColor(Color.white)
            Text("Streak: 3")
                .foregroundColor(Color.white)
            HStack() {
                Text("Lifetime Lift Increase: ").font(.title)
                    .foregroundColor(Color.white)
                    .padding(.leading, -10)
            }
            Text("Bench Press: +0")
                .foregroundColor(Color.white)
            Text("Squat: +0")
                .foregroundColor(Color.white)
            Text("Deadlift: +0")
                .foregroundColor(Color.white)
            
            Spacer()
        }       
        .padding(.leading, 50)
        .padding(.top, 20)
        .font(.title2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
    }
}
