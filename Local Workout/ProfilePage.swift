import SwiftUI
import FirebaseAuth

struct ProfilePage: View {
    @ObservedObject var viewModel: SharedViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.darkGray, Color.coolGray]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack {
                // Changing Split
                Text("Split:")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .padding(.bottom, 0)
                Picker("Split", selection: $viewModel.split) {
                    Text("Push Pull Legs").tag("Push Pull Legs")
                    Text("Upper Lower").tag("Upper Lower")
                }
                // Sign Out Button
                Button(action: {
                    signOut()
                }) {
                    Text("Sign Out")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .padding()
                        .frame(maxWidth: 200)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                }
                .padding(.horizontal, 20)
                
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Sign Out"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            alertMessage = "User signed out successfully"
            showAlert = true
        } catch let signOutError as NSError {
            alertMessage = "Error signing out: \(signOutError.localizedDescription)"
            showAlert = true
        }
    }
}

struct SignOutPage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage(viewModel: SharedViewModel())
    }
}
