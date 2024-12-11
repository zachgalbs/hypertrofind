import SwiftUI
import SwiftData

@main
struct HypertrofindApp: App {
    @State private var data = HypertrofindData()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(data)
        }
    }
}
