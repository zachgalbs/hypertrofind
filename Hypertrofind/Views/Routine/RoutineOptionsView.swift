import SwiftUI

struct RoutineOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @State var routine: Routine
    @Environment(HypertrofindData.self) var data
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
                .background(Colors.shared.backgroundColor)
                .frame(width: 350)
                .clipShape(.buttonBorder)
            }
        }
    }
    private func deleteRoutine() {
        print("deleted!")
        data.routines.removeAll { $0.hashValue == routine.hashValue }
        saveJson(data: data.routines, to: "routines")
    }
}
