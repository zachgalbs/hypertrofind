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
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Title
                    Text("Sign Up")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    // Text Fields
                    Group {
                        CustomSignUpTextField(placeholder: "Username", text: $username, isSecure: false, errorMessage: $usernameError)
                        CustomSignUpTextField(placeholder: "Email", text: $email, isSecure: false, errorMessage: $emailError, keyboardType: .emailAddress)
                        CustomSignUpTextField(placeholder: "Password", text: $password, isSecure: true, errorMessage: $passwordError)
                        CustomSignUpTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, errorMessage: $confirmPasswordError)
                    }
                    
                    // Sign Up Button
                    Button(action: signUpButtonTapped) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.fieryOrange, Color.brightYellow]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15.0)
                            .shadow(radius: 10)
                    }
                    .padding(.top, 20)
                    
                    // Sign In Link
                    NavigationLink(destination: SignInPage(viewModel: viewModel)) {
                        Text("Already have an account? Sign In")
                            .foregroundColor(.white)
                            .underline()
                            .padding(.top, 10)
                    }
                    
                    // Generic Error Message
                    if !genericError.isEmpty {
                        Text(genericError)
                            .font(.caption)
                            .foregroundColor(.softRed)
                            .padding(.top, 10)
                    }
                }
                .padding()
            }
        }
    }
    
    func signUpButtonTapped() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                self.clearErrors()
                
                if username.isEmpty {
                    usernameError = "You can't have an empty username"
                    return
                }
                if email.isEmpty {
                    emailError = "You can't have an empty email"
                    return
                }
                if password.isEmpty {
                    passwordError = "You can't have an empty password"
                    return
                }
                if password != confirmPassword {
                    confirmPasswordError = "Passwords do not match"
                    return
                }

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
                return
            } else {
                self.clearErrors()
                let db = Firestore.firestore()
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
                viewModel.isUserAuthenticated = true
            }
            
            guard let _ = authResult else {
                self.genericError = "An unexpected error occurred. Please try again."
                return
            }
        }
    }

    func clearErrors() {
        self.usernameError = ""
        self.emailError = ""
        self.passwordError = ""
        self.confirmPasswordError = ""
        self.genericError = ""
    }
}

// Custom TextField for better styling and reusability
struct CustomSignUpTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool
    @Binding var errorMessage: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading) {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10.0)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10.0)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
            }
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.softRed)
                    .padding(.top, 5)
            }
        }
        .padding(.bottom, 15)
    }
}

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage(viewModel: SharedViewModel())
    }
}

// Custom Colors Extension
extension Color {
    static let electricBlue = Color(red: 0.0, green: 123.0/255.0, blue: 1.0)
    static let vibrantGreen = Color(red: 40.0/255.0, green: 167.0/255.0, blue: 69.0/255.0)
    static let fieryOrange = Color(red: 1.0, green: 87.0/255.0, blue: 51.0/255.0)
    static let brightYellow = Color(red: 1.0, green: 193.0/255.0, blue: 7.0/255.0)
    static let lightGray = Color(red: 248.0/255.0, green: 249.0/255.0, blue: 250.0/255.0)
    static let darkGray = Color(red: 52.0/255.0, green: 58.0/255.0, blue: 64.0/255.0)
    static let coolGray = Color(red: 108.0/255.0, green: 117.0/255.0, blue: 125.0/255.0)
    static let turquoise = Color(red: 23.0/255.0, green: 162.0/255.0, blue: 184.0/255.0)
    static let softRed = Color(red: 220.0/255.0, green: 53.0/255.0, blue: 69.0/255.0)
}
