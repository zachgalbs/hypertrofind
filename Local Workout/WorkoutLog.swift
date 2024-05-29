import SwiftUI
import WebKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct WorkoutLog: View {
    @ObservedObject var viewModel: SharedViewModel
    @State private var exercises: [UserExercise] = []
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
                    HStack {
                        SplitHeader(viewModel: viewModel)
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
    @State private var weekdayButtons: [WeekdayButton] = [
        WeekdayButton(day: "Monday", symbol: "m"),
        WeekdayButton(day: "Tuesday", symbol: "t"),
        WeekdayButton(day: "Wednesday", symbol: "w"),
        WeekdayButton(day: "Thursday", symbol: "t"),
        WeekdayButton(day: "Friday", symbol: "f"),
        WeekdayButton(day: "Saturday", symbol: "s"),
        WeekdayButton(day: "Sunday", symbol: "s")
    ]
    @State private var selectedDay: String = ""
    
    var body: some View {
        HStack {
            ForEach(weekdayButtons.indices, id: \.self) { index in
                Button(action: {
                    selectDay(at: index)
                }) {
                    Image(systemName: "\(weekdayButtons[index].symbol).circle\(weekdayButtons[index].isButtonPressed ? ".fill" : "")")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                }
            }
        }
        .padding(.top, 18)
    }
    
    private func selectDay(at index: Int) {
        for i in weekdayButtons.indices {
            weekdayButtons[i].isButtonPressed = (i == index)
        }
        selectedDay = weekdayButtons[index].day
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

struct ExerciseView: View {
    @ObservedObject var viewModel: SharedViewModel
    @Binding var exercise: UserExercise
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
                            viewModel.showInstructionView = viewModel.showInstructionView ? false: true
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
    @Binding var exercise: UserExercise

    var body: some View {
        Button(action: {
            exercise.sets.append(Set())
        }) {
        Image(systemName: "plus.square")
            .font(.title2)
            .frame(width: 40, height: 40)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .foregroundStyle(Color.blue)
        }
        .padding(.leading, 10)
    }
}

struct RemoveSetButton: View {
    @Binding var exercise: UserExercise

    var body: some View {
        Button(action: {
            if !exercise.sets.isEmpty {
                exercise.sets.removeLast()
            }
        }) {
            Image(systemName: "minus.square")
                .font(.title2)
                .frame(width: 40, height: 40)
                .foregroundStyle(Color.red)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            }
    }
}

struct RemoveExerciseButton: View {
    @Binding var exercises: [UserExercise]
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
    @Binding var exercises: [UserExercise]
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
                            exercises.append(UserExercise(name: selectedExercise.name, sets: [Set()]))
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

struct SplitHeader: View {
    @ObservedObject var viewModel: SharedViewModel
    
    var body: some View {
        VStack {
            Spacer() // Pushes content to center
            if (viewModel.split == "Push Pull Legs") {
                Picker("Muscle Group", selection: $viewModel.muscleGroup) {
                    Text("Push").tag("Push")
                    Text("Pull").tag("Pull")
                    Text("Legs").tag("Legs")
                }
                .padding(.leading, -30)
                .scaleEffect(1.5)
            } else if (viewModel.split == "Upper Lower") {
                Picker("Muscle Group", selection: $viewModel.muscleGroup) {
                    Text("Upper").tag("Upper")
                    Text("Lower").tag("Lower")
                }
                .padding(.leading, -30)
                .scaleEffect(1.5)
            }
            Spacer() // Pushes content to center
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures VStack takes full available space
    }
}

struct ExercisePicker: View {
    @State public var availableEquipment: [String] = []
    @State public var possibleExercises: [DatabaseExercise] = []
    @State private var filteredExercises: [DatabaseExercise] = []
    @Binding var exercises: [UserExercise]
    @State public var idealPushWorkout: [String] = ["Barbell Incline Bench Press", "Machine Shoulder (Military) Press", "Triceps Pushdown", "Cable Rope Overhead Triceps Extension", "Bent Over Cable Flye", "Cable Lateral Raise"]
    @State public var idealPullWorkout: [String] = ["One Arm Lat Pulldown", "Pull Up", "Bent Over Barbell Row", "Cable Shrugs", "Reverse Machine Flyes", "High Cable Curls"]
    @State public var idealLegsWorkout: [String] = ["Barbell Squat", "Leg Extensions", "Seated Leg Curl", "Seated Calf Raise"]
    @ObservedObject var viewModel: SharedViewModel
    var exerciseVideoIds: [VideoID]
    
    var body: some View {
        Text("Generating:")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .font(.title)
            .bold()
            .foregroundStyle(Color.blue)
            .padding(.leading, -50)
            .onAppear {
                makeWorkout()
            }
    }
    struct DatabaseExercise: Decodable {
        let name: String
        let force: String?
        let level: String
        let mechanic: String?
        let equipment: String?
        let primaryMuscles: [String]
        let secondaryMuscles: [String]
        let instructions: [String]
        let category: String
    }
    struct ExerciseData: Decodable {
        let exercises: [DatabaseExercise]
    }
    func fetchLocationDocument(documentId: String, completion: @escaping () -> Void) {
        let docRef = Firestore.firestore().collection("locations").document(documentId.lowercased())
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let equipmentList = document.get("equipment") as? [String] {
                    DispatchQueue.main.async {
                        availableEquipment = equipmentList
                        completion()
                    }
                } else {
                    print("No equipment list found or it's not in the expected format.")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    public func makeWorkout() {
        generatePossibleExercises {
            checkForIdealExercises()
            self.filterPossibleExercises {
                
            }
        }
    }
    private func checkForIdealExercises() {
        @State var idealWorkout: [String]
        if (viewModel.muscleGroup == "Push") {
            idealWorkout = idealPushWorkout
        }
        if (viewModel.muscleGroup == "Pull") {
            idealWorkout = idealPullWorkout
        }
    if (viewModel.muscleGroup == "Legs") {
            idealWorkout = idealLegsWorkout
        }
        for exerciseName in idealPushWorkout {
            if let matchingExercise = possibleExercises.first(where: { $0.name == exerciseName }) {
                var newUserExercise = UserExercise(name: exerciseName, sets: [], description: "", videoID: "")
                newUserExercise.description = matchingExercise.instructions.joined(separator: "\n")
                newUserExercise.sets = [Set(weight: 0, reps: 0, isButtonPressed: false)]
                exercises.append(newUserExercise)
            }
        }
    }
    private func generatePossibleExercises(completion: @escaping () -> Void) {
        print("generating!")
        viewModel.shouldGenerateExercises = false
        // getting the JSON exercise file
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let exercisesData = try decoder.decode(ExerciseData.self, from: data)
            // once you fetch the location document, do the following code:
            fetchLocationDocument(documentId: (viewModel.currentLocation?.title)!) {
                self.possibleExercises = exercisesData.exercises.filter { exercise in
                    guard let equipment = exercise.equipment else {
                        return false
                    }
                    for exerciseAlreadyAdded in exercises {
                        if (exercise.name == exerciseAlreadyAdded.name) {
                            return false
                        }
                    }
                    if (self.availableEquipment.contains(equipment) || equipment == "other" || equipment == "body only") {
                        return true
                    } else {
                        return false
                    }
                }
                self.viewModel.shouldGenerateExercises = false
                completion()
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    private func filterPossibleExercises(completion: @escaping () -> Void) {
        filteredExercises = possibleExercises.filter { exercise in
            guard let equipment = exercise.equipment else {
                return false
            }
            if (equipment == "body only" || equipment == "other") {
                return false
            }
            if (exercise.force != viewModel.muscleGroup.lowercased()) {
                return false
            }
            if (exercise.level == "beginner") {
                return false
            }
            else {
                return true
            }
        }
        completion()
    }
}

struct FinishWorkoutView: View {
    @Binding var exercises: [UserExercise]
    var body: some View {
        HStack() {
            Spacer()
            if (!exercises.isEmpty) {
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
                .padding(.trailing, 50)
            }
            Spacer()
        }
    }
    private func LogWorkout() {
        print("Logging workout")
        let db = Firestore.firestore()

        // If there is a currentUser, let's add their exercises to their record
        if let currentUser = Auth.auth().currentUser {
            var workoutData: [String: Any] = [:]
            var exercisesData: [[String: Any]] = []

            // Prepare data for each exercise
            for exercise in exercises {
                var setsData: [[String: Any]] = []
                for set in exercise.sets {
                    if (set.isButtonPressed) {
                        setsData.append([
                            "weight": set.weight,
                            "reps": set.reps
                        ])
                    }
                }
                exercisesData.append([
                    "name": exercise.name,
                    "sets": setsData
                ])
            }

            // Prepare the workout data
            workoutData["exercises"] = exercisesData
            workoutData["date"] = Timestamp(date: Date())  // Capture the current date and time of the workout

            // Add the workout data to the current user's workouts collection
            let workoutRef = db.collection("users").document(currentUser.uid).collection("workouts").document()
            workoutRef.setData(workoutData) { error in
                if let error = error {
                    print("Error logging workout: \(error)")
                } else {
                    print("Workout logged successfully with ID: \(workoutRef.documentID)")
                }
            }
        } else {
            print("No user is currently signed in.")
        }
        exercises = []
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
struct WeekdayButton {
    let day: String
    let symbol: String
    var isButtonPressed: Bool = false
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

struct UserExercise {
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

