import SwiftUI

struct LocationView: View {
    @State private var searchText: String = ""
    @State private var items: [Location] = []
    @Binding var isSearchBarActive: Bool
    @State var selectedEquipment: [String] = []
    var filteredItems: [Location] {
        if searchText.isEmpty {
            return items.map { $0 }
        } else {
            isSearchBarActive = true    
            return items.map { $0 }.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            NavigationView {
                VStack(alignment: .leading) {
                    List {
//                        Section(header: Text("Recents")
//                            .font(.title3)
//                            .foregroundColor(.black)
//                            .bold()
//                            .textCase(nil)
//                            .padding(0)
//                        ) {
                            ForEach(filteredItems, id: \.self) { item in
                                NavigationLink(destination: RoutineView(fromLocationView: true, location: item)) {
                                    Text(item.name)
                                }
                            }
                        //}
                    }
                }
                .searchable(text: $searchText, prompt: "24 hour fitness...")
                .navigationTitle("Locations")
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: CustomLocation()){
                            Image(systemName: "plus.app")
                                .foregroundStyle(Color.black)
                                .font(.title2)
                        }
                    }
                })
            }
            .onAppear {
                if let locations: [Location] = loadJson(from: "locations.json") {
                    items = locations
                }
            }
        }
        .background(Color.white) // Set the background color of the sheet
        .cornerRadius(20) // Apply rounded corners
        .shadow(radius: 10) // Optional: Add a shadow for a floating effect
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LocationView(isSearchBarActive: .constant(false))
}
