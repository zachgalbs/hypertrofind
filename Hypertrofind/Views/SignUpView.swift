//
//  SignUpView.swift
//  Hypertrofind
//
//  Created by Zachary Galbraith on 6/16/24.
//

import SwiftUI
import AuthenticationServices

class ButtonState: ObservableObject {
    @Published var isSignUpClicked: Bool = false
    @Published var isSignInClicked: Bool = true
}

struct LoginView: View {
    @ObservedObject var buttonState = ButtonState()
    var body: some View {
        VStack {
            ZStack {
                Color.gray
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    Text("Hypertrofind")
                        .font(.title)
                        .bold()
                    Spacer() // Adjust the space between the text and the buttons
                    HStack {
                        SignUpButtonView(buttonState: buttonState)
                        SignInButtonView(buttonState: buttonState)
                    }
                }
            }
            VStack {
                if (buttonState.isSignInClicked) {
                    SignInView()
                } else {
                    SignUpView()
                }
                Spacer()
            }
        }
    }
}

private struct SignUpButtonView: View {
    @ObservedObject var buttonState: ButtonState
    
    var body: some View {
        VStack {
            Button(action: {
                buttonState.isSignUpClicked.toggle()
                if buttonState.isSignUpClicked {
                    buttonState.isSignInClicked = false
                }
            }) {
                Text("Sign Up")
                    .fontWeight(buttonState.isSignUpClicked ? .bold : .regular)
                    .frame(width: 150, height: 50)
            }
            .foregroundStyle(Color.white)
            
            Rectangle()
                .fill(buttonState.isSignUpClicked ? Color.purple : Color.clear)
                .frame(height: 4)
                .frame(width: 200)
                .animation(.easeInOut, value: buttonState.isSignUpClicked)
        }
    }
}
private struct SignInButtonView: View {
    @ObservedObject var buttonState: ButtonState
    var body: some View {
        VStack {
            Button(action: {
                buttonState.isSignInClicked.toggle()
                if buttonState.isSignInClicked {
                    buttonState.isSignUpClicked = false
                }
            }) {
                Text("Sign In")
                    .fontWeight(buttonState.isSignInClicked ? .bold : .regular)
                    .frame(width: 150, height: 50)
            }
            .foregroundStyle(Color.white)
            
            Rectangle()
                .fill(buttonState.isSignInClicked ? Color.purple : Color.clear)
                .frame(height: 4)
                .frame(width: 200)
                .animation(.easeInOut, value: buttonState.isSignInClicked)
        }
    }
}
private struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.circle")
                TextField("Username", text: $username)
                Spacer()
            }
            .font(.title3)
            .padding(.leading)
            Divider()
            HStack {
                Image(systemName: "lock")
                TextField("Password", text: $password)
                Spacer()
            }
            .font(.title3)
            .padding(.leading)
            .padding(.top)
            Divider()
        }
        .padding(.top, 20)
    }
}
private struct SignInView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.circle")
                TextField("Username", text: $username)
                Spacer()
            }
            .font(.title3)
            .padding(.leading)
            Divider()
            HStack {
                Image(systemName: "lock")
                Spacer()
            }
            .font(.title3)
            .padding(.leading)
            .padding(.top)
            Divider()
            SignInWithAppleButtonView()
                .frame(width: 280, height: 60)
        }
        .padding(.top, 20)
    }
}
struct SignInWithAppleButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}

#Preview {
    LoginView()
}
