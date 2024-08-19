//
//  SetOptionsView.swift
//  Hypertrofind
//
//  Created by Zachary Galbraith on 8/10/24.
//

import SwiftUI

struct SetOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var sets: Int
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
                    sets -= 1
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
}
