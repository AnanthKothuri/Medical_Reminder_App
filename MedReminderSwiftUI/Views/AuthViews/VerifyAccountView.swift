//
//  VerifyAccountView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/5/22.
//

import SwiftUI

struct VerifyAccountView: View {
    let auth = AuthManager()
    @State var username: String
    @State private var code = ""
    @State var errorMessage = ""
    @Binding var canReturn : Bool
    
    @Binding var rootActive : Bool
    
    var body: some View {
        
        ZStack {
            Color.init(.sRGB, red: 255, green: 255, blue: 255, opacity: 0.8)

            VStack(alignment: .center, spacing: nil) {
                
                // x out button
                Button(action: {
                    canReturn.toggle()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding()
                })
                    .alignmentGuide(.leading, computeValue: {
                        d in d[.leading]
                    })
                
                // text descriptions
                Text("Verification Code")
                    .font(Font.custom("NunitoSans-SemiBold", size: 30))
                    .padding()
                
                Text("If a verification code has been sent to your email, enter it here. If you did not recieve an email, then resend the code or use another email when you create an account.")
                    .font(Font.custom("NunitoSans-Light", size: 12))
                    .padding()
                    .multilineTextAlignment(.center)
                
                
                Text(errorMessage)
                    .font(Font.custom("NunitoSans-Light", size: 12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blue)
                
                TextField("Username", text: $username)
                    .padding()
                    .frame(width: 150, height: 30, alignment: .center)
                    .font(Font.custom("NunitoSans-Regular", size: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.blue, lineWidth: 1)
                    )
                    .padding()
                
                //Code text field
                TextField("_ _ _ _ _ _", text: $code)
                    .padding()
                    .multilineTextAlignment(.center)
                    .font(Font.custom("NunitoSans-Regular", size: 40, relativeTo: .title))
                    .padding()
                
                //buttons
                VStack {
                    // enter button
                    Button("Enter", action: {
                        enterPressed()
                        
                    })
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .padding()
                        .font(Font.custom("NunitoSans-SemiBold", size: 14))
                    
                    // resend code button
                    Button("Resend Code", action: {
                        resendCode()
                    })
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .font(Font.custom("NunitoSans-SemiBold", size: 14))
                }
                
                Spacer()
            }
            .padding(Edge.Set.leading, 40)
            .padding(Edge.Set.trailing, 40)
            
            
        }
        .cornerRadius(40)
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(.blue, lineWidth: 1))
        
        .padding()
    }
    
    
    // methods
    
    func resendCode() {
        if username == "" {
            errorMessage = "Username cannot be empty"
            return
        }
        
        auth.resendConfirmationCode(username: username)
    }
    
    func enterPressed() {
        if code == "" || code.count != 6 {
            errorMessage = "Invalid code"
            return
        }
//        guard let numCode = Int(code) else {
//            errorLabel.text = "Invalid code"
//            return
//        }
        
        if username == "" {
            errorMessage = "Username cannot be empty"
            return
        }
        
        // confirming code
        let worked = auth.confirmSignUp(username: username, code: code)
        if !worked {
            errorMessage = "Invalid code"
            return
        }
        
        // worked, unwind to Login
        errorMessage = "Verification Successful!"
        rootActive.toggle()
    }
}

struct VerifyAccountView_Previews: PreviewProvider {


    static var previews: some View {
        VerifyAccountView(username: "", canReturn: .constant(true), rootActive: .constant(false))
    }
}
