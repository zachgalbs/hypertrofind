import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 1

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack {
                TabView(selection: $selectedTab) {
                    ChartView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Chart")
                        }
                        .tag(0)
                    
                    RoutineView()
                        .tabItem {
                            Image(systemName: "figure.strengthtraining.traditional")
                            Text("Strength")
                        }
                        .tag(1)
                    LocationView()
                        .tabItem {
                            Image(systemName: "location.fill")
                            Text("Location")
                        }
                        .tag(2)
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.crop.circle.fill")
                            Text("Profile")
                        }
                        .tag(3)
                }
            }
            
            VStack {
                Spacer()
                NavbarView(selectedTab: $selectedTab)
                    .frame(height: 80) // Fixed height for the custom navbar
            }
        }
    }
}

private struct NavbarView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                NavBarItem(iconName: "chart.line.uptrend.xyaxis", isSelected: selectedTab == 0)
                    .onTapGesture { selectedTab = 0 }
                
                Spacer()
                
                NavBarItem(iconName: "figure.strengthtraining.traditional", isSelected: selectedTab == 1)
                    .onTapGesture { selectedTab = 1 }
                
                Spacer()
                
                NavBarItem(iconName: "location.fill", isSelected: selectedTab == 2)
                    .onTapGesture { selectedTab = 2 }
                
                Spacer()
                
                NavBarItem(iconName: "person.crop.circle.fill", isSelected: selectedTab == 3)
                    .onTapGesture { selectedTab = 3 }
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}

struct NavBarItem: View {
    let iconName: String
    let isSelected: Bool
    
    var body: some View {
        Image(systemName: iconName)
            .font(.title)
            .foregroundColor(isSelected ? Color.blue : Color.gray)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
