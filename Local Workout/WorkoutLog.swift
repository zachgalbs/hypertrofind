import SwiftUI
import WebKit

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

struct Set {
    var weight: Double = 0
    var reps: Int = 0
    var isButtonPressed: Bool = false
}

struct Exercise {
    var name: String = ""
    var sets: [Set]
}

struct VideoID: Identifiable {
    var name: String = ""
    var id: String = ""
}

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
                    HeaderView()
                    ForEach(exercises.indices, id: \.self) { exerciseIndex in
                        ExerciseView(
                            exercise: $exercises[exerciseIndex],
                            videoID: exerciseVideoIds.first(where: { $0.name == exercises[exerciseIndex].name })?.id ?? "",
                            selectedVideoID: $selectedVideoID,
                            onDelete: {
                                exercises.remove(at: exerciseIndex)
                            }
                        )
                    }
                }
                .padding(.leading, 50)
            }
            AddExerciseButton(showPopup: $showPopup, exercises: $exercises, newExerciseName: newExerciseName)
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

// Break down your view into smaller subviews

struct HeaderView: View {
    var body: some View {
        Text("Day 2 | Friday")
            .font(.largeTitle)
            .bold()
            .foregroundColor(Color.white)
            .padding(.leading, -20)
    }
}

struct locationBar: View {
    var body: some View {
        Text("")
    }
}

struct ExerciseView: View {
    @Binding var exercise: Exercise
    let videoID: String
    @Binding var selectedVideoID: String?
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(exercise.name)
                    .font(.title)
                    .foregroundColor(.white)

                Spacer() // This will push the content to the sides

                Label("", systemImage: "video.fill")
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        selectedVideoID = selectedVideoID == videoID ? nil : videoID
                    }

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                        .padding(10)
                }
            }

            if selectedVideoID == videoID {
                YouTubeView(videoID: videoID)
                    .frame(height: 200)
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
            if selectedVideoID == videoID {
                YouTubeView(videoID: videoID)
                    .frame(height: 200)
                    .cornerRadius(12)
            }
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
    @Binding var exercises: [Exercise]
    var newExerciseName: String

    var body: some View {
        VStack {
            Spacer() // Pushes everything below to the bottom
            HStack {
                Spacer() // Centers the button horizontally
                Button(action: {
                    showPopup = true
                }) {
                    Text("Add Exercise")
                        .font(.custom("normalText", size: 15))
                        .foregroundColor(Color.white)
                        .frame(width: 300, height: 40)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                Spacer() // Centers the button horizontally
            }
            .padding(.bottom, 20) // Adds some padding at the bottom
        }
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
#Preview {
    WorkoutList()
}

