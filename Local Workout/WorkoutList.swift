import SwiftUI
import WebKit

struct YouTubeViewPractice: UIViewRepresentable {
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

struct WorkoutList: View {
    @State private var selectedVideoID: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            workoutView(exerciseName: "Pull Up", videoID: "iWpoegdfgtc")
            workoutView(exerciseName: "Underhand Pull Up", videoID: "9JC1EwqezGY")
            workoutView(exerciseName: "Inverted Row", videoID: "KOaCM1HMwU0")
            workoutView(exerciseName: "Push Up", videoID: "mm6_WcoCVTA")
            workoutView(exerciseName: "Inverted Skull Crusher", videoID: "1lrjpLuXH4w")
        }
        .foregroundColor(.white)
        .font(.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
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
            if selectedVideoID == videoID {
                YouTubeView(videoID: videoID)
                    .frame(height: 200)
                    .cornerRadius(12)
            }
        }
    }
}

#Preview {
    WorkoutList()
}
