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
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Welcome Back!")
                        .font(.system(size: 20, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .padding(.bottom, 5)
                    Text("Sign In")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    if !genericError.isEmpty {
                        Text(genericError)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.bottom, 15)
                    }
                    
                    // Email Text Field
                    CustomSignInTextField(placeholder: "Email", text: $email, isSecure: false, errorMessage: $emailError, keyboardType: .emailAddress)
                    
                    // Password Text Field
                    CustomSignInTextField(placeholder: "Password", text: $password, isSecure: true, errorMessage: $passwordError)
                    
                    // Sign In Button
                    Button(action: signIn) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15.0)
                            .shadow(radius: 10)
                    }
                    .padding(.top, 20)
                    
                    // Sign Up Button
                    NavigationLink(destination: SignUpPage(viewModel: viewModel)) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.white)
                            .underline()
                            .padding(.top, 10)
                    }
                }
                .padding()
            }
        }
    }
    
    func signIn() {
        if email.isEmpty {
            emailError = "Please enter a valid email address."
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            self.clearErrors()
            if let error = error as NSError? {
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
            } else {
                viewModel.isUserAuthenticated = true
            }
        }
    }
    
    func clearErrors() {
        self.emailError = ""
        self.passwordError = ""
        self.genericError = ""
    }
}

struct CustomSignInTextField: View {
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
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
        .padding(.bottom, 15)
    }
}

struct SignInPage_Previews: PreviewProvider {
    static var previews: some View {
        SignInPage(viewModel: SharedViewModel())
    }
}
