import SwiftUI
import Foundation
struct LocationBuilderView: View {
    @State var name: String = ""
    @State var equipment: [String] = []
    @Environment(\.dismiss) var dismiss
    @Environment(HypertrofindData.self) var data
    @State private var showSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.shared.backgroundColor
                    .ignoresSafeArea(.all)
                VStack {
                    
                    Text("New Location")
                        .font(.largeTitle)
                        .bold()
                    
                    
                    TextField("Location Name", text: $name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Text("Equipment")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            showSheet = true
                        }) {
                            Image(systemName: "plus.square")
                                .font(.title)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    
                    EquipmentListView(name: $name, equipment: $equipment)
                    
                    Button(action: {
                        var locations: [Location] = data.locations
                        let lowercaseEquipment: [String] = equipment.map { $0.lowercased() }
                        if name == "" {name = "Untitled"}
                        let location = Location(name: name, equipment: lowercaseEquipment)
                        locations.append(location)
                        saveJson(data: locations, to: "locations")
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
                .padding()
            }
        }
        .sheet(isPresented: $showSheet) {
            searchSheetView(equipment: $equipment)
        }
    }
}

// InputView to handle user input
private struct EquipmentListView: View {
    @Binding var name: String
    @Binding var equipment: [String]
    
    var body: some View {
        VStack {
            List {
                ForEach(equipment.indices, id: \.self) { index in
                    HStack {
                        Text(equipment[index])
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                }
                .onDelete(perform: delete)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    func delete(at offsets: IndexSet) {
        equipment.remove(atOffsets: offsets)
    }
}
private struct searchView: View {
    var body: some View {
       Text("something")
    }
}

struct searchSheetView: View {
    @State private var possibleEquipment: [String] = []
    @State private var searchText: String = ""
    @Binding var equipment: [String]
    @State var pieceOfEquipment: String = ""
    @Environment(\.dismiss) var dismiss
    @Environment(HypertrofindData.self) var data
    
    var body: some View {
        NavigationView {
            VStack {
                List(filteredEquipment, id: \.self) { item in
                    Button(action: {
                        pieceOfEquipment = item
                        equipment.append(pieceOfEquipment)
                        dismiss()
                    }) {
                        Text(item)
                    }
                }
            }
            .background(Colors.shared.backgroundColor)
            .onAppear {
                possibleEquipment = findPossibleEquipment()
            }
            .searchable(text: $searchText, prompt: "Search equipment...")
            .navigationTitle("Add Equipment")
        }
    }
    
    private var filteredEquipment: [String] {
        if searchText.isEmpty {
            return possibleEquipment
        } else {
            return possibleEquipment.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func findPossibleEquipment() -> [String] {
        var equipment: [String] = []
        for exercise in data.exercises {
            let equip = exercise.equipment
            if !equipment.contains(equip) {
                equipment.append(equip)
            }
        }
        return equipment
    }
}

#Preview {
    LocationBuilderView()
}
