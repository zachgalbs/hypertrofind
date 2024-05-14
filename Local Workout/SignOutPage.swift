import SwiftUI
import FirebaseAuth

struct SignOutPage: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack {
                // Title
                Text("Sign Out")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // Subtitle
                Text("We hope to see you again soon!")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 40)
                
                // Sign Out Button
                Button(action: {
                    signOut()
                }) {
                    Text("Sign Out")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                }
                .padding(.horizontal, 40)
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
        SignOutPage()
    }
}
