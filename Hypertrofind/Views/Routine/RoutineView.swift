import SwiftUI

struct RoutineView: View {
    @State var fromLocationView: Bool = false
    @State var location: Location?
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.2)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    // For the top right button
                    HStack {
                        Spacer()
                        AddRoutineButton()
                    }
                    // For the Routine Buttons
                    RoutineButtonsView(fromLocationView: fromLocationView, location: location)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct RoutineButtonsView: View {
    @State var fromLocationView: Bool
    @State var location: Location?
    var body: some View {
        VStack {
            if let loadedRoutines: [Routine] = loadJson(from: "routines.json") {
                if (!loadedRoutines.isEmpty) {
                    HStack {
                        ForEach(loadedRoutines, id: \.name) { routine in
                            RoutineButtonView(routine: routine, generateCustomRoutine: fromLocationView, location: location)
                        }
                    }
                }
                else {
                    Text("Get Started")
                        .font(.title)
                        .bold()
                    Text("To get started, make your first routine")
                }
            }
        }
        .padding(.top, 50)
    }
}

struct RoutineButtonView: View {
    @State var routine: Routine
    @State private var isEllipsisPressed = false
    @State var generateCustomRoutine: Bool
    @State var location: Location?
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 16) { // Adjust spacing as needed
                NavigationLink(destination: {
                    if generateCustomRoutine {
                        GenerateCustomRoutineView(location: location ?? Location(name: "", equipment: []), routine: routine)
                    } else {
                        ActiveWorkoutPageView(routine: routine)
                    }
                }) {
                    HStack {
                        Text(routine.name)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 16)
                        Spacer()
                        Button(action: {
                            isEllipsisPressed.toggle()
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .padding(.trailing, 16)
                                .sheet(isPresented: $isEllipsisPressed) {
                                    RoutineOptionsView(routine: routine)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                }
            }
            .padding(.horizontal, 16) // Add horizontal padding for consistent layout
        }
        .frame(height: 80) // Set a fixed height to avoid smushing
        .padding(.vertical, 8) // Add vertical padding between buttons
    }
}

struct AddRoutineButton: View {
    @State private var moveUp = true
    @State private var isAnimating = true
    @State private var timer: Timer?

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: RoutineBuilderView()) {
                    Image(systemName: "plus.app")
                        .offset(y: moveUp ? -5 : 5)
                        .padding()
                        .font(.largeTitle)
                        .foregroundColor(Color.gray)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 2, y: 2)
                }
            }
            .onAppear {
                if let loadedRoutines: [Routine] = loadJson(from: "routines.json") {
                    if (loadedRoutines.count <= 0) {
                        startAnimation()
                    }
                }
            }
        }
    }

    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            withAnimation(Animation.easeInOut(duration: 1)) {
                self.moveUp.toggle()
            }
        }
    }

    private func stopAnimation() {
        self.moveUp = false
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    RoutineView()
}
