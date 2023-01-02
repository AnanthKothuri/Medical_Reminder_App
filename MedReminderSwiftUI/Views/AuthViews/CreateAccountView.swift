//
//  CreateAccountView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/4/22.
//

import SwiftUI

struct CreateAccountView: View {
    let auth = AuthManager()
    @State private var isCreateButton = false
    @State private var errorMessage = ""
    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var canSegue = false
    
    @Binding var rootActive : Bool
    
    var body: some View {
        
        ZStack {
            VStack {
                Text("Create Account")
                    .font(Font.custom("NunitoSans-Bold", size: 30))
                    .padding()
                Text(errorMessage)
                    .font(Font.custom("NunitoSans-Light", size: 14))
                    .foregroundColor(.blue)
                    .padding()
                    .multilineTextAlignment(.center)
                VStack {
                    TextField("Full Name", text: $fullName)
                        .padding()
                        .frame(width: 250, height: nil, alignment: .top)
                        .font(Font.custom("NunitoSans-Regular", size: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.blue, lineWidth: 1)
                        )
                    TextField("Username", text: $username)
                        .padding()
                        .frame(width: 250, height: nil, alignment: .top)
                        .font(Font.custom("NunitoSans-Regular", size: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.blue, lineWidth: 1)
                        )
                        .disableAutocorrection(true)
                    TextField("Email", text: $email)
                        .padding()
                        .frame(width: 250, height: nil, alignment: .top)
                        .font(Font.custom("NunitoSans-Regular", size: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.blue, lineWidth: 1)
                        )
                        .disableAutocorrection(true)
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 250, height: nil, alignment: .top)
                        .font(Font.custom("NunitoSans-Regular", size: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.blue, lineWidth: 1)
                        )
                        .disableAutocorrection(true)
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .frame(width: 250, height: nil, alignment: .top)
                        .font(Font.custom("NunitoSans-Regular", size: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.blue, lineWidth: 1)
                        )
                        .disableAutocorrection(true)
                }
                .padding()
                
                Divider()
                    .padding()
                
                Button(action: {
                    let goodFields = verifyAllFields()
                    if !goodFields {
                        return
                    }
                    
                    let error = auth.signUp(username: username, password: password, fullName: fullName, email: email)
                    
                    // catching errors with username/ password combination
                    if let err = error {
                        var finalError = ""
                        if (err.contains("Password")) {
                            finalError = "Password must have at least 8 characters, 1 number, 1 capital and lowercase letters, and 1 special character "
                        } else if (err.contains("User already exists")) {
                            finalError = "Username already exists"
                        }
                        
                        errorMessage = finalError
                        return
                    }
                    
                    // switching from false to true
                    canSegue = true
                    isCreateButton = true
                    
                }) {
                    Text("Create Account")
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .font(Font.custom("NunitoSans-SemiBold", size: 14))
                .padding()
                
                // send code button
                Button("Send Code") {
                    canSegue.toggle()
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .font(Font.custom("NunitoSans-SemiBold", size: 14))
                
                // checking whether to show the VerifyAccountView
            }
            
            ZStack {
                if canSegue {
                    if isCreateButton {
                        VerifyAccountView(username: username, canReturn: $canSegue, rootActive: $rootActive)
                            .transition(.move(edge: .bottom))
                            .animation(.spring())
                    } else {
                        VerifyAccountView(username: "", canReturn: $canSegue, rootActive: $rootActive)
                            .transition(.move(edge: .bottom))
                            .animation(.spring())
                    }
                }
            }
            .zIndex(2.0)
            
            Spacer()
            
        }
        
    }
    
    // other methods
    func verifyAllFields() -> Bool {
        guard fullName != "" else {
            errorMessage = "Full name cannot be empty"
            return false
        }
        guard username != "" else {
            errorMessage = "Username cannot be empty"
            return false
        }
        guard email != "" else {
            errorMessage = "Email cannot be empty"
            return false
        }
        guard password != "" else {
            errorMessage = "Password cannot be empty"
            return false
        }
        guard confirmPassword != "" &&
            confirmPassword == password else {
            errorMessage = "Password and Confirm Password must match"
            return false
        }
        let str = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let fn = str.components(separatedBy: " ")
        guard fn.count == 2 else {
            errorMessage = "Full name must contain a first and last name"
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Invalid email address"
            return false
        }
        
        return true
    }
    
    
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView(rootActive: .constant(false))
    }
}
