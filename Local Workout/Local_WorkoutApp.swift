import SwiftUI

@main
struct Local_WorkoutApp: App {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemGray
    }
    var body: some Scene {
        WindowGroup {
            TabView {
                Home()
                    .tabItem {
                        Label("Statistics", systemImage: "chart.line.uptrend.xyaxis")
                    }
                WorkoutLog()
                    .tabItem {
                        Label("Routines", systemImage: "figure.strengthtraining.traditional")
                    }
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                WorkoutList()
                    .tabItem {
                        Label("Workout List", systemImage: "list.bullet")
                    }
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                //LocationManager()
            }
        }
    }
}
