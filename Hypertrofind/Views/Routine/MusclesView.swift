import SwiftUI

struct MusclesView: View {
    @State private var muscles: [String] = []
    @State private var selectedMuscles: Set<String> = []
    @State private var searchText: String = ""
    @State var location: Location
    @Environment(HypertrofindData.self) var data
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Muscles To Train")
                .font(.title2)
                .bold()
                .padding(.bottom, 10)
            
            NavigationView {
                VStack {
                    List {
                        ForEach(filteredMuscles, id: \.self) { muscle in
                            HStack {
                                Image(systemName: "bolt.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                                
                                Text(muscle)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.leading, 10)
                                
                                Spacer()
                                
                                // Checkbox for selection
                                Image(systemName: selectedMuscles.contains(muscle) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selectedMuscles.contains(muscle) ? .blue : .gray)
                                    .onTapGesture {
                                        toggleSelection(of: muscle)
                                    }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                            .shadow(radius: 5)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .searchable(text: $searchText, prompt: "Search for a muscle...")
                }
                .navigationTitle("Muscles")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // Action for settings or adding new muscle
                        }) {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                }
            }
            Spacer()
            
            NavigationLink(destination: GenerateView(location: location, muscles: selectedMuscles)){
                Text("Confirm")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .onAppear() {
                getListOfMuscles()
            }
        }
        .padding()
    }
    
    var filteredMuscles: [String] {
        if searchText.isEmpty {
            return muscles
        } else {
            return muscles.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func getListOfMuscles() {
        for exercise in data.exercises {
            for muscle in exercise.primaryMuscles {
                if !muscles.contains(muscle) {
                    muscles.append(muscle)
                }
            }
        }
    }
    
    private func toggleSelection(of muscle: String) {
        if selectedMuscles.contains(muscle) {
            selectedMuscles.remove(muscle)
        } else {
            selectedMuscles.insert(muscle)
        }
    }
}

#Preview {
    MusclesView(location: Location(name: "no location found", equipment: []))
}
