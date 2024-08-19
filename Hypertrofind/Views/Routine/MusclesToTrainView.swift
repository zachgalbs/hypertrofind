import SwiftUI

struct MusclesToTrainView: View {
    @State private var selectedMuscles: [String: Bool] = [
        "Chest": false,
        "Back": false,
        "Shoulders": false,
        "Legs": false,
        "Arms": false,
        "Abs": false
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select the muscles you want to train:")
                .font(.headline)
                .padding(.bottom, 10)
            
            ForEach(selectedMuscles.keys.sorted(), id: \.self) { muscle in
                Toggle(isOn: Binding(
                    get: { self.selectedMuscles[muscle] ?? false },
                    set: { self.selectedMuscles[muscle] = $0 }
                )) {
                    Text(muscle)
                }
                .toggleStyle(CheckboxToggleStyle())
            }
            
            Spacer()
            
            Button(action: {
                // Handle the selected muscles (e.g., save or proceed)
            }) {
                Text("Confirm")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

#Preview {
    MusclesToTrainView()
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}
