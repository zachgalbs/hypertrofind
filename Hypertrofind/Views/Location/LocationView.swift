import SwiftUI

struct LocationView: View {
    @State private var searchText: String = ""
    @State private var items: [Location] = []
    @Binding var isSearchBarActive: Bool
    @State var selectedEquipment: [String] = []
    @Environment(HypertrofindData.self) var data
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
                        ForEach(filteredItems, id: \.self) { item in
                            NavigationLink(destination: MusclesView(location: item) ) {
                                Text(item.name)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "24 hour fitness...")
                .navigationTitle("Locations")
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: LocationBuilderView()){
                            Image(systemName: "plus.app")
                                .foregroundStyle(Color.black)
                                .font(.title2)
                        }
                    }
                })
            }
            .onAppear {
                items = data.locations
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
