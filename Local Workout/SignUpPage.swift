import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct SignUpPage: View {
    @ObservedObject var viewModel: SharedViewModel
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var usernameError: String = ""
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var confirmPasswordError: String = ""
    @State private var genericError: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 5)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                if !usernameError.isEmpty {
                    Text(usernameError)
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
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 5)
                if !confirmPasswordError.isEmpty {
                    Text(confirmPasswordError)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 15)
                }
                NavigationLink(destination: SignInPage(viewModel: viewModel)) {
                    Text("Sign In")
                        .foregroundStyle(Color.blue)
                }
                Button(action: signUpButtonTapped) {
                    Text("Sign Up")
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
    }
    
    func signUpButtonTapped() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                self.clearErrors()
                
                if (username.isEmpty) {
                    usernameError = "You can't have an empty username"
                    return
                }
                else if (email.isEmpty) {
                    emailError = "You can't have an empty email"
                    return
                }
                else if (password.isEmpty) {
                    passwordError = "You can't have an empty password"
                    return
                }
                // Check if the error is due to the email already being in use
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    self.emailError = "This email is already in use. Please use a different email."
                case AuthErrorCode.weakPassword.rawValue:
                    self.passwordError = "Password is too weak. It should be at least 6 characters."
                case AuthErrorCode.operationNotAllowed.rawValue:
                    self.genericError = "Email/password accounts are not enabled. Please contact support or try a different sign-in method."
                case AuthErrorCode.tooManyRequests.rawValue:
                    self.genericError = "We have detected too many requests from your device. Please try again later."
                case AuthErrorCode.networkError.rawValue:
                    self.genericError = "A network error occurred. Please check your internet connection and try again."
                case AuthErrorCode.invalidEmail.rawValue:
                    self.emailError = "The email address is badly formatted. Please enter a valid email address."
                default:
                    self.genericError = "An unexpected error occurred. Please try again. Error: \(error.localizedDescription)"
                }
                // Return or handle the error (e.g., update UI)
                return
            }
            // if we can create a user,
            else {
                self.clearErrors()
                let db = Firestore.firestore()
                // if we can get the currentUser
                if let user = Auth.auth().currentUser {
                    db.collection("users").document(user.uid).setData(["username": username]) { error in
                        if let error = error {
                            print("Error writing document: \(error)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } else {
                    print("can't get the current user")
                }
                viewModel.isUserAuthenticated = true // This will trigger the navigation
            }
            
            guard let _ = authResult else {
                self.genericError = "An unexpected error occurred. Please try again."
                return
            }
            
            // If the creation was successful, you can proceed to add the user's information to Firestore
            // or navigate to another part of your app
        }
    }

    // Utility function to clear previous errors before attempting to sign up again
    func clearErrors() {
        self.usernameError = ""
        self.emailError = ""
        self.passwordError = ""
        self.confirmPasswordError = ""
        self.genericError = ""
    }
}

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage(viewModel: SharedViewModel())
    }
}

