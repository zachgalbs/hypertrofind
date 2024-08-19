import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0

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
                    MapView()
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


#Preview {
    MainView()
}
