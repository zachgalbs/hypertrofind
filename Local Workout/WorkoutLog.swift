import SwiftUI
import WebKit

struct WorkoutLog: View {
    @ObservedObject var viewModel: SharedViewModel
    @State private var exercises: [Exercise] = []
    @State var exerciseVideoIds: [VideoID] = [VideoID(name: "Pull Up", id: "iWpoegdfgtc"), VideoID(name: "Underhand Pull Up", id: "9JC1EwqezGY"), VideoID(name: "Inverted Row", id: "KOaCM1HMwU0"), VideoID(name: "Push Up", id: "mm6_WcoCVTA"), VideoID(name: "Inverted Skull Crusher", id: "1lrjpLuXH4w")]
    @State private var showPopup = false
    @State private var newExerciseName = ""
    @State private var selectedVideoID: String?
    @State private var keyboardVisible: Bool = false
    let numbers = 0...25

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        HeaderView()
                        AddExerciseButton(showPopup: $showPopup)
                    }
                    if viewModel.shouldGenerateExercises {ExercisePicker( exercises: $exercises, viewModel: viewModel, exerciseVideoIds: exerciseVideoIds)}
                    ForEach(exercises.indices, id: \.self) { exerciseIndex in
                        ExerciseView(
                            viewModel: viewModel,
                            exercise: $exercises[exerciseIndex],
                            videoID: exerciseVideoIds.first(where: { $0.name == exercises[exerciseIndex].name })?.id ?? "",
                            videoLabelClicked: false,
                            infoCircleClicked: false,
                            onDelete: {
                                exercises.remove(at: exerciseIndex)
                            }
                        )
                    }
                    FinishWorkoutView(exercises: $exercises)
                }
                .padding(.leading, 50)
            }
            PopupView(showPopup: $showPopup, newExerciseName: $newExerciseName, exercises: $exercises, exerciseVideoIds: $exerciseVideoIds)
        }
        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
        .overlay(DismissKeyboardOverlay(keyboardVisible: $keyboardVisible))
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
            keyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            keyboardVisible = false
        }
    }
}

struct HeaderView: View {
    var body: some View {
        Text("Day 1 | Monday")
            .font(.largeTitle)
            .bold()
            .foregroundColor(Color.white)
            .padding(.leading, -20)
            .padding(.top, 10)
    }
}

struct ExerciseView: View {
    @ObservedObject var viewModel: SharedViewModel
    @Binding var exercise: Exercise
    let videoID: String?
    @State var videoLabelClicked: Bool
    @State var infoCircleClicked: Bool
    @State private var popupClicked = false
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(exercise.name)
                    .font(.title)
                    .foregroundColor(.white)

                Spacer() // This will push the content to the sides
                
                if (videoID != "") {
                    Label("", systemImage: "video.fill")
                        .foregroundColor(Color.blue)
                        .onTapGesture {
                            print("videoID: " + videoID!)
                            videoLabelClicked = videoLabelClicked ? false : true
                        }
                } else {
                    Label("", systemImage: "info.circle")
                        .foregroundStyle(Color.blue)
                        .onTapGesture {
                            viewModel.currentInstructions = exercise.description
                            infoCircleClicked = infoCircleClicked ? false : true
                        }
                }

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                        .padding(10)
                }
            }
            if (videoLabelClicked) {
                YouTubeView(videoID: videoID!)
                    .frame(height: 200)
                    .cornerRadius(12)
            }
            if (videoID == "" && infoCircleClicked) {
                InstructionView(text: exercise.description, infoCircleClicked: $infoCircleClicked)
                    .frame(height: 300)
                    .cornerRadius(12)
            }

            ForEach(exercise.sets.indices, id: \.self) { index in
                SetView(set: $exercise.sets[index], setNumber: index + 1)
                    .foregroundColor(.white)
                    .font(.title)
            }

            HStack {
                AddSetButton(exercise: $exercise)
                RemoveSetButton(exercise: $exercise)
            }
        }
        .padding(.bottom, 10)
        .padding(.top, 0)
    }
}

struct WorkoutVideoView: View {
    var exerciseName: String
    var videoID: String
    @Binding var selectedVideoID: String?

    var body: some View {
        VStack {
            HStack {
                Text(exerciseName)
                Label("", systemImage: "video.fill")
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        selectedVideoID = selectedVideoID == videoID ? nil : videoID
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            YouTubeView(videoID: videoID)
                .frame(height: 200)
                .cornerRadius(12)
        }
    }
}

struct SetView: View {
    @Binding var set: Set
    let numbers = 0...25
    let setNumber: Int
    
    private let weightFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximum = 1000 // Maximum value
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Set \(setNumber)")
            }
            HStack {
                Text("Weight:")
                    .font(.title3)
                    .foregroundColor(Color.white)
                TextField("lbs", value: $set.weight, formatter: weightFormatter)
                    .keyboardType(.numberPad)
                    .foregroundStyle(Color.white)
                    .padding(.leading, 4)
                    .border(Color.black)
                    .font(.title3)
                Spacer()
                Button(action: {
                    set.isButtonPressed.toggle()
                }) {
                    Image(systemName: set.isButtonPressed ? "checkmark.circle.fill" : "checkmark.circle")
                        .padding(.leading, 50)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundStyle(Color.white)
                }
            }
            HStack {
                Text("Reps Completed:")
                    .font(.title3)
                    .foregroundColor(Color.white)
                Picker("Reps: ", selection: $set.reps) {
                    ForEach(numbers, id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .tint(.white)
                .pickerStyle(MenuPickerStyle())
            }
        }
        .padding(.top, 10)
        .padding(.leading, 10)
        .border(Color.black)
        .padding([.trailing, .leading], 10)
    }
}

struct AddSetButton: View {
    @Binding var exercise: Exercise

    var body: some View {
        Button(action: {
            exercise.sets.append(Set())
        }) {
            Text("Add Set")
                .font(.custom("normalText", size: 15))
                .frame(width: 120, height: 30)
                .background(Color.black)
                .foregroundColor(Color.white)
                .cornerRadius(8)
        }
        .padding(.leading, 10)
    }
}

struct RemoveSetButton: View {
    @Binding var exercise: Exercise

    var body: some View {
        Button(action: {
            if !exercise.sets.isEmpty {
                exercise.sets.removeLast()
            }
        }) {
            Text("Remove Set")
                .font(.custom("normalText", size: 15))
                .frame(width: 120, height: 30)
                .background(Color.red)
                .foregroundColor(Color.white)
                .cornerRadius(8)
        }
    }
}

struct AddExerciseButton: View {
    @Binding var showPopup: Bool

    var body: some View {
        Button(action: {showPopup = true}) {
            Image(systemName: "plus.circle")
                .font(.title2)
                .frame(width: 40, height: 40)
                .foregroundStyle(Color.white)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
        }
        .padding(.top, 18)
        .padding(.leading, 50)
    }
}

struct RemoveExerciseButton: View {
    @Binding var exercises: [Exercise]
        var exerciseIndex: Int

        var body: some View {
            Button(action: {
                exercises.remove(at: exerciseIndex)
            }) {
                Text("Remove Exercise")
                    .font(.custom("normalText", size: 15))
                    .frame(width: 120, height: 30)
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
            }
        }
}

struct PopupView: View {
    @Binding var showPopup: Bool
    @Binding var newExerciseName: String
    @Binding var exercises: [Exercise]
    @Binding var exerciseVideoIds: [VideoID]
    @State private var selectedExerciseId: String = "iWpoegdfgtc"

    var body: some View {
        if showPopup {
            HStack {
                Spacer()
                VStack {
                    Picker("Exercise: ", selection: $selectedExerciseId) {
                        ForEach(exerciseVideoIds) { videoId in
                            Text(videoId.name).tag(videoId.id)
                        }
                    }
                    Button("Add Exercise") {
                        if let selectedExercise = exerciseVideoIds.first(where: { $0.id == selectedExerciseId }) {
                            exercises.append(Exercise(name: selectedExercise.name, sets: [Set()]))
                        }
                        showPopup = false
                        newExerciseName = ""
                    }
                    .padding()
                    .foregroundColor(Color.white)
                    .background(Color.black)
                    .cornerRadius(10)
                }
                .frame(width: 300, height: 200)
                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                .cornerRadius(12)
                .shadow(radius: 20)
                .overlay(
                    Button(action: { showPopup = false }) {
                        Image(systemName: "xmark.circle")
                            .padding()
                    },
                    alignment: .topTrailing
                )
                Spacer()
            }
            .padding(.top, 100)
        }
    }
}

struct ExercisePicker: View {
    @Binding var exercises: [Exercise]
    @ObservedObject var viewModel: SharedViewModel
    var exerciseVideoIds: [VideoID]
    
    var body: some View {
        Text("Split: " + viewModel.split)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .font(.title)
            .bold()
            .foregroundStyle(Color.blue)
            .padding(.leading, -50)
            .onAppear {
                addThreeRandomExercises()
            }
    }
    private func addThreeRandomExercises() {
        print("addThreeRandomExercises running!")
        print("viewModel.possibleExercises: \(viewModel.possibleExercises)")

        // Make a mutable copy of possibleExercises to modify it safely
        var tempPossibleExercises = viewModel.possibleExercises

        // Ensure we don't attempt to add more exercises than available in the list
        let numberOfExercisesToAdd = min(3, tempPossibleExercises.count)

        if exercises.count < 3 {
            for _ in 1...numberOfExercisesToAdd {
                if let randomIndex = tempPossibleExercises.indices.randomElement() {
                    let randomExercise = tempPossibleExercises.remove(at: randomIndex)
                    
                    let newExercise = Exercise(name: randomExercise.name, sets: [Set()], description: randomExercise.instructions[0])

                    if let matchingVideoID = exerciseVideoIds.first(where: { $0.name == randomExercise.name })?.id {
                        print("Found matching video ID: \(matchingVideoID) for \(randomExercise.name)")
                        // Example: newExercise.videoID = matchingVideoID
                    } else {
                        print("Matching video ID not found for \(randomExercise.name)")
                    }

                    exercises.append(newExercise)
                } else {
                    print("No random exercise name available")
                    break // Exit the loop if no exercises are available to prevent unnecessary iterations
                }
            }
        }

        print("Added exercises:")
        print(exercises)
    }
}

struct FinishWorkoutView: View {
    @Binding var exercises: [Exercise]
    var body: some View {
        HStack() {
            Spacer()
            Button(action: {
                LogWorkout()
            }) {
                Text("Finish Workout")
                    .fontWeight(.semibold)
                    .foregroundColor(.white) // Set the text color to white (or any color you prefer)
                    .padding() // Add some padding inside the button for better aesthetics
            }
            .background(Color.blue) // Set the background color of the button
            .clipShape(RoundedRectangle(cornerRadius: 10)) // Make the button corners rounded
            .padding() // Add padding around the button to avoid clipping and for better spacing
            .padding(.trailing, 50)
            Spacer()
        }
    }
    private func LogWorkout() {
        var completedExercises: [CompletedExercise] = [
            //CompletedExercise(name: exercises[0].name, sets: CompletedSet(weight: exercises[0].sets[0].weight, reps: exercises[0].sets[0].reps))
        ]
    }
}



struct DismissKeyboardOverlay: View {
    @Binding var keyboardVisible: Bool

    var body: some View {
        Group {
            if keyboardVisible {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct YouTubeView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)") else {
            print("Invalid URL")
            return
        }
        uiView.load(URLRequest(url: url))
    }
}

struct InstructionView: View {
    let text: String
    @Binding var infoCircleClicked: Bool
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(text)
                    .padding()
                    .padding(.trailing, 5)
                    .foregroundColor(Color.white)
                    .background(Color.black)
                    .cornerRadius(10)
            }
                .cornerRadius(12)
                .shadow(radius: 20)
                .overlay(
                Button(action: {infoCircleClicked = false}) {
                    Image(systemName: "xmark.circle")
                        .padding(.trailing, 5)
                        .padding(.top, 5)
                },
                alignment: .topTrailing
            )
            Spacer()
        }
    }
}

struct Set {
    var weight: Double = 0
    var reps: Int = 0
    var isButtonPressed: Bool = false
}
struct CompletedSet {
    var weight: Double = 0
    var reps: Int = 0
}

struct Exercise {
    var name: String = ""
    var sets: [Set]
    var description: String = ""
    var videoID: String = ""
}

struct CompletedExercise {
    var name: String = ""
    var sets: [CompletedSet]
}

struct VideoID: Identifiable {
    var name: String = ""
    var id: String = ""
}

#Preview {
    WorkoutLog(viewModel: SharedViewModel())
}

