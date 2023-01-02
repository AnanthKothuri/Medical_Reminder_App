//
//  LoginView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/4/22.
//

import SwiftUI
import Speech

struct LoginView: View {
    @State private var user : User?
    var util = Utils()
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""

    @State private var segue = false
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Log In ")
                        .font(Font.custom("NunitoSans-Bold", size: 40))
                        .padding(Edge.Set.top, -80)
                    
                    Text(errorMessage)
                        .font(Font.custom("NunitoSans-Light", size: 14))
                        .foregroundColor(.blue)

                    TextField("Username or email", text: $username)
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
                    
                    // log in button
                    Button(action: {
                        // auth logic
                        let worked = util.auth.login(username: username, password: password)

                        if worked == true {
                            errorMessage = "Success!"
                            segue.toggle()
                            
                        } else {
                            errorMessage = "Invalid Username or Password"
                        }
                    }, label: {
                        Text("Log in")
                    })

                    .padding()
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .font(Font.custom("NunitoSans-SemiBold", size: 14))
                    
                    Divider()
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                    
                    HStack {
                        NavigationLink(destination: CreateAccountView(rootActive: $isActive), isActive: $isActive) {
                            Text("Create Account")
                        }
                        .padding()
                        .font(Font.custom("NunitoSans-Light", size: 14))
                        Button("Forgot Password") {
                            
                        }
                        .padding()
                        .font(Font.custom("NunitoSans-Light", size: 14))
                    }
                }
                .padding()
                
                ZStack {
                    // login worked
                    
                    if segue {
                        let response = initializeUser(username: username.lowercased())
                        
                        
                        if response[0] as! Bool {
                            
                            MainTabView(
                                user: response[1] as! User, util: util)
                                .transition(.move(edge: .trailing))
                                .animation(.easeOut)
                        } else {
                            CompleteProfileView(
                                util: util
                            )
                                .transition(.move(edge: .trailing))
                                .animation(.spring())
                        }
                    }
                }
            }
            .navigationTitle("Log in")
            .navigationBarHidden(true)
        }

        .onAppear {
            // requesting permission for notifications
            NotificationHandler.shared.requestPermission( onDeny: {
                
            })
            
            // requesting permission for audio to text detection
            SFSpeechRecognizer.requestAuthorization { authStatus in
                
                // do stuff with this
            }
        }
    }

    
    func initializeUser(username: String) -> [Any] {
        let response = util.api.containsID(userID: username)!
        
        if let val = response["True"] {
            let userType = val as! String
            util.api.loginUser(userID: username, userType: userType)
            
            let userResponse = util.api.getUser(getUserID: username, getUserType: userType)

            let u = util.dictToUser(dictionary: userResponse)!
            
            // adding user to default memory for background tasks
            util.saveToUserDefaults(user: u)
            
            return [true, u]

        } else {
            // this is a new user, finish setting up profile
            return [false]
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

