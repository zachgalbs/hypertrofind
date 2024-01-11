import SwiftUI
import WebKit

struct YouTubeView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        print("updateUIView called with videoID: \(videoID)")

        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)") else {
            print("Invalid URL")
            return
        }

        print("Loading URL: \(url)")
        uiView.load(URLRequest(url: url))
    }
}

struct Set {
    var weight: String = ""
    var reps: Int = 0
    var isButtonPressed: Bool = false
}
struct Exercise {
    var name: String = ""
    var sets: [Set]
}
struct VideoID {
    var name: String = ""
    var id: String = ""
}

struct WorkoutLog: View {
    @State private var exercises: [Exercise] = [Exercise(name: "Pull Up", sets: [Set()])]
    @State private var exerciseVideoIds: [VideoID] = [VideoID(name: "Pull Up", id: "iWpoegdfgtc"), VideoID(name: "Underhand Pull Up", id: "9JC1EwqezGY")]
    @State private var showPopup = false
    @State private var newExerciseName = ""
    @State private var selectedVideoID: String?
    @State private var keyboardVisible: Bool = false
    let numbers = 0...25
    
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading, spacing: 15) {
                Text("Day 2 | Friday").font(.largeTitle)
                    .bold()
                    .foregroundColor(Color.white)
                    .padding(.leading, -20)
                ForEach(exercises.indices, id: \.self) { exerciseIndex in
                    workoutView(exerciseName: exercises[exerciseIndex].name, videoID: exerciseVideoIds[exerciseIndex].id) // The ID for the Pull Up Exercise
                        .foregroundColor(.white)
                        .bold()
                        .font(.title)
                    ForEach(exercises[exerciseIndex].sets.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Set \(index + 1)")
                                .foregroundStyle(Color.white)
                                .italic()
                                .padding(.leading, 5)
                                .opacity(exercises[exerciseIndex].sets[index].isButtonPressed ? 0.5 : 1.0)
                            VStack(alignment: .leading, spacing: 0) {
                                HStack() {
                                    Text("Weight:").font(.title3)
                                        .foregroundColor(Color.white)
                                    TextField("45", text: $exercises[exerciseIndex].sets[index].weight)
                                        .keyboardType(.numberPad)
                                        .foregroundStyle(Color.white)
                                        .padding(.leading, 4)
                                        .border(Color.black)
                                    Button(action: {
                                        exercises[exerciseIndex].sets[index].isButtonPressed.toggle()
                                    }) {
                                        Image(systemName: exercises[exerciseIndex].sets[index].isButtonPressed ? "checkmark.circle.fill" : "checkmark.circle")
                                            .padding(.leading, 50)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .foregroundStyle(Color.white)
                                    }
                                }
                                HStack() {
                                    Text("Reps Completed:").font(.title3)
                                        .foregroundColor(Color.white)
                                    Picker("Reps: ", selection: $exercises[exerciseIndex].sets[index].reps) {
                                        ForEach(numbers, id: \.self) { number in
                                            Text("\(number)").tag(number)
                                        }
                                    }
                                    .tint(.white)
                                    .pickerStyle(MenuPickerStyle())
                                }
                            }
                            .padding(.leading, 10)
                        }
                        .border(Color.black)
                        .padding(.trailing, 20)
                        .padding(.leading, 10)
                    }
                    VStack() {
                        // BUTTON TO ADD SETS
                        Button(action: {
                            // CALLING ADDSET
                            addSet(indexOfExercise: exerciseIndex)
                        }) {
                            Text("Add Set")
                                .font(.custom("normalText", size: 15))
                                .frame(width: 120, height: 30)
                                .background(Color.black)
                                .foregroundColor(Color.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.leading, 10)
                }
                // BUTTON FOR ADDING EXERCISE
                Button(action: {
                    //Action for the button
                    showPopup = true
                    print(exercises[0].sets)
                })
                {
                    Text("Add Exercise")
                        .font(.custom("normalText", size: 15))
                        .foregroundColor(Color.white)
                        .frame(width: 120, height: 40)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                // SHOWING THE POPUP
                if showPopup {
                    VStack {
                        Picker("Exercise ", newExerciseName) {
                            ForEach(numbers, id: \.self) { number in
                                Text("\(number)").tag(number)
                            }
                        }
                        Button("Add Exercise") {
                            addExercise(name: newExerciseName)
                            showPopup = false
                            newExerciseName = ""
                        }
                        .padding()
                    }
                    .frame(width: 300, height: 200)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 20)
                    .overlay(
                        Button(action: { showPopup = false }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                        },
                        alignment: .topTrailing
                    )
                }
            }
            .padding(.leading, 50)
            .font(.title2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
        .overlay(
            Group {
                if keyboardVisible {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.hideKeyboard()
                        }
                }
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
            keyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            keyboardVisible = false
        }
    }
    private func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func addExercise(name: String) {
        exercises.append(Exercise(name: name, sets: [Set()]))
        showPopup = false
    }
    func addSet(indexOfExercise: Int) {
        //ADDING A BLANK SET TO THE LIST OF SETS
        exercises[indexOfExercise].sets.append(Set())
    }
    func workoutView(exerciseName: String, videoID: String) -> some View {
        VStack {
            HStack {
                Text(exerciseName)
                Label("", systemImage: "video.fill")
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        if selectedVideoID == videoID {
                            selectedVideoID = nil // Hide the player if the same button is tapped
                        } else {
                            selectedVideoID = videoID // Show the player for the tapped exercise
                        }
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if selectedVideoID == videoID {
                YouTubeView(videoID: videoID)
                    .frame(height: 200)
                    .cornerRadius(12)
            }
                Spacer()
        }
    }
}

struct ExerciseInputView: View {
    @Binding var newExerciseName: String
    var onAdd: () -> Void

    var body: some View {
        VStack {
            TextField("Enter Exercise Name", text: $newExerciseName)
                .padding()
            Button("Add Exercise", action: onAdd)
        }
        .padding()
    }
}

#Preview {
    WorkoutLog()
}
