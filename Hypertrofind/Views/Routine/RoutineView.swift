import SwiftUI

struct RoutineView: View {
    @State var fromLocationView: Bool = false
    @State var location: Location?
    @Environment(HypertrofindData.self) var data
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.shared.backgroundColor
                    .ignoresSafeArea(.all)
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
    @Environment(HypertrofindData.self) var data
    var body: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        VStack {
            if (!data.routines.isEmpty) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(data.routines, id: \.name) { routine in
                        RoutineButtonView(routine: routine, generateCustomRoutine: fromLocationView, location: location)
                    }
                }
            }
            else {
                Text("Get Started")
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.white)
                Text("To get started, make your first routine")
                    .foregroundStyle(Color.gray)
                    .font(.title3)
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
    @State var counter: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 16) {
                NavigationLink(destination: {
                    if generateCustomRoutine {
                        GenerateView(location: location ?? Location(name: "", equipment: []), routine: routine)
                    } else {
                        ActiveWorkoutView(routine: routine)
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
    @Environment(HypertrofindData.self) var data

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
                if (data.routines.count <= 0) {
                    startAnimation()
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
