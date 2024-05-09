import SwiftUI
import FirebaseAuth

struct SignInPage: View {
    @ObservedObject var viewModel: SharedViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var emailError: String = ""
    @State var passwordError: String = ""
    @State var genericError: String = ""
    var body: some View {
        VStack {
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            if !genericError.isEmpty {
                Text(genericError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.bottom, 15)
            }
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 5)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            if !emailError.isEmpty {
                Text(emailError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.bottom, 15)
            }
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 5)
            if !passwordError.isEmpty {
                Text(passwordError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.bottom, 15)
            }
            
            Button(action: signIn) {
                Text("Sign In!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15.0)

            }
        }
        .padding()
    }
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if (email.isEmpty) {
                emailError = "Please enter a valid email address."
                return
            }
            if let error = error as NSError? {
                self.clearErrors()
                switch error.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    self.passwordError = "The password is incorrect"
                case AuthErrorCode.tooManyRequests.rawValue:
                    self.genericError = "We have detected too many requests from your device. Please try again later."
                case AuthErrorCode.networkError.rawValue:
                    self.genericError = "A network error occurred. Please check your internet connection and try again."
                case AuthErrorCode.invalidEmail.rawValue:
                    self.emailError = "Please enter a valid email address."
                default:
                    self.genericError = "An unexpected error occurred. Please try again. Error: \(error.localizedDescription)"
                }
                return
            }
            else {
                viewModel.isUserAuthenticated = true
                self.clearErrors()
            }
        }
    }
    func clearErrors() {
        self.emailError = ""
        self.passwordError = ""
        self.genericError = ""
    }
}
